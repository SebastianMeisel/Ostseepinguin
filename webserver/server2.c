#include <arpa/inet.h>      // For manipulating IP addresses
#include <errno.h>          // For error reporting
#include <fcntl.h>          // For file control options
#include <netinet/in.h>     // For IPv4 and IPv6 socket address structures
#include <signal.h>         // For signal handling
#include <stdio.h>          // For standard I/O operations
#include <stdlib.h>         // For standard library functions
#include <string.h>         // For string manipulation functions
#include <sys/sendfile.h>   // For file transfer
#include <sys/socket.h>     // For socket programming
#include <unistd.h>         // For POSIX operating system API

// Global variables
int open_fd;            // File descriptor for opened file
int client_socket;      // File descriptor for client socket
int server_socket;      // File descriptor for server socket

// Function to return a substring from pos to the first occurrence of char or the end
char* substring(const char *buffer, int pos, char c, char **error) {
  // Check if buffer is NULL
  if (buffer == NULL) {
    *error = "Buffer is NULL";
    return NULL;
  }

  // Check if pos is within the bounds of the buffer
  int buffer_length = strlen(buffer);
  if (pos < 0 || pos >= buffer_length) {
    *error = "Invalid position";
    return NULL;
  }

  // Find the index of the first occurrence of char after pos
  const char *ptr = buffer + pos;
  int index = pos;
  while (*ptr != '\0' && *ptr != c) {
    ptr++;
    index++;
  }

  // Allocate memory for the substring
  char *substring = (char*)malloc((index - pos + 1) * sizeof(char));
  if (substring == NULL) {
    *error = "Memory allocation failed";
    return NULL;
  }

  // Copy the substring into the allocated memory
  strncpy(substring, buffer + pos, index - pos);
  substring[index - pos] = '\0';  // Null-terminate the substring

  return substring;
}

// Signal handler for termination (SIGTERM) signal
void termination_handler(int signum) {
  // Close all file descriptors and exit
  close(open_fd);
  close(client_socket);
  close(server_socket);
  exit(0);
}

// Signal handler for interrupt (SIGINT) signal
void sigint_handler(int signum) {
  // Call the termination handler
  termination_handler(signum);
}

// Main function
int main() {
  // Declaration of variables
    char first_three[4];            // Variable to store the first three characters of the client buffer
    char oldfile[45];               // Variable to store the previously requested file
    char requested_file[45];        // Variable to store the requested file (if any)
    char standard_file[45] = "index.html";  // Standard file

  // Set up signal handling for SIGINT (Ctrl+C)
  struct sigaction new_action, old_action;
  new_action.sa_handler = sigint_handler;
  sigemptyset(&new_action.sa_mask);
  new_action.sa_flags = 0;
  sigaction(SIGINT, &new_action, NULL);

  // Set up server address structure
  struct sockaddr_in addr = {
    AF_INET,            // IPv4
    0x901f,             // Port 8080 (hexadecimal 0x1f90, reverse bytes)
    0                   // IP address (0.0.0.0)
  };

  // Create server socket
  server_socket = socket(AF_INET, SOCK_STREAM, 0);
  if (server_socket == -1) {
    perror("server_socket");
    exit(1);
  }

  // Bind server socket to address
  if (bind(server_socket, (struct sockaddr*)&addr, sizeof(addr)) == -1) {
    perror("bind");
    close(server_socket);
    exit(1);
  }

  // Listen for incoming connections
  if (listen(server_socket, 10) == -1) {
    perror("listen");
    close(server_socket);
    exit(1);
  }

  // Main loop to accept and handle client requests
  while (1) {
    // Accept client connection
    client_socket = accept(server_socket, NULL, NULL);
    if (client_socket == -1) {
      perror("client_socket");
      close(server_socket);
      exit(1);
    }

    // Receive data from client
    char client_buffer[65536] = {0};
    if (recv(client_socket, client_buffer, 65536, MSG_CMSG_CLOEXEC) == -1) {
      // Error handling for receive
      continue;
    }
        
    // Extract filename from client request
    char *error = NULL;
    char* file = substring(client_buffer, 5, ' ', &error);
    if (file == NULL) {
      // Error handling for substring extraction
      continue;
    }

    // Process HTTP request
    // Extract the first three characters from the client buffer to check if it's a GET request
    strncpy(first_three, client_buffer, 3);
    first_three[3] = '\0'; // Null terminator

    // If it's not a GET request, continue to the next iteration of the loop
    if (strcmp(first_three, "GET") != 0) {
      continue;
    }

    // Compare the requested file with the previously requested file
    if (strcmp(file, oldfile) == 0) {
      continue; // If the requested file is the same as the previous one, continue to the next iteration
    }

    // If the requested file is not empty, use it; otherwise, use the standard file ("index.html")
    if (strcmp(file, "") != 0) {
      strncpy(requested_file, file, sizeof(requested_file) - 1);
    } else {
      strncpy(requested_file, standard_file, sizeof(requested_file) - 1);
    }

    // Open the requested file
    open_fd = open(requested_file, O_RDONLY);
    if (open_fd == -1 && strcmp(requested_file, "") == 0) {
      // If the file is not found, send a 404 response
      if (errno == ENOENT) {
        dprintf(client_socket, "HTTP/1.1 404 Not Found\r\nContent-Type: text/plain\r\n\r\nFile not found.\n");
        close(client_socket);
        continue;
      } else {
        // If there's another error, send a 500 response
        perror("open");
        dprintf(client_socket, "HTTP/1.1 500 Internal Server Error\r\n\r\n");
        close(client_socket);
        continue;
      }
    } else if (open_fd == -1) {
      // If there's an error opening the file, send a 500 response
      perror("open");
      dprintf(client_socket, "HTTP/1.1 500 Internal Server Error\r\n\r\n");
      close(client_socket);
      continue;
    }

    // Get the size of the file
    int file_size = lseek(open_fd, 0, SEEK_END);
    lseek(open_fd, 0, SEEK_SET); // Reset file pointer

    // Send the HTTP response header
    dprintf(client_socket, "HTTP/1.1 200 OK\r\nContent-Type: text/html ; charset=utf-8\r\nContent-Length: %d\r\n\r\n", file_size);

    // Send the file contents
    sendfile(client_socket, open_fd, 0, file_size);

    // Update the oldfile variable if the requested file is different from the previous one
    if (strcmp(requested_file, "") == 0) {
      strcpy(oldfile, standard_file);
    } else {
      if (strcmp(file, oldfile) != 0) {
        strcpy(oldfile, requested_file);
      }
    }

    // Close client socket
    // Close the file descriptor and client socket
    close(open_fd);
    close(client_socket);
    // Free dynamically allocated memory
    free(file);
  }

  return 0;
}

/* Local Variables: */
/* jinx-languages: "en_US" */
/* End: */
