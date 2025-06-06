#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/sendfile.h>
#include <sys/socket.h>
#include <unistd.h>

int open_fd;
int client_socket;
int server_socket;

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
void termination_handler(int signum)
{
  // For the moment just make sure, all file handlers are cloesed
  close(open_fd);
  close(client_socket);
  close(server_socket);
  exit(0);
}

void sigint_handler(int signum)
{
    // Handle SIGINT (Ctrl+C) signal to break the loop
    // You can handle additional cleanup here if needed
    // For now, simply call the termination handler
    termination_handler(signum);
}

void main () {
  // Set up signal handling for SIGTERM and SIGINT
  struct sigaction new_action, old_action;
  new_action.sa_handler = sigint_handler;
  sigemptyset(&new_action.sa_mask);
  new_action.sa_flags = 0;
  sigaction(SIGINT, &new_action, NULL);

  struct sockaddr_in addr = {
    AF_INET,			/* IPv4 */
    0x901f, 			/* hex(8080) = 0x1f90 => reverse bytes  */
    0
  };

  // Bind and listen to 0.0.0.0/0 on port 8080
  server_socket = socket(AF_INET, SOCK_STREAM, 0);
  if (server_socket == -1) {
    perror("server_socket");
    exit(1);
  }

  if (bind(server_socket, &addr, sizeof(addr)) == -1) {
    perror("bind");
    close(server_socket);
    exit(1);
  }

  if (listen(server_socket, 10) == -1){
    perror("listen");
    close(server_socket);
    exit(1);
  }


  // create 65536 byte client buffer 
  char client_buffer[65536] = {0};
  char* file;

  // Get first 3 chars to check for GET
  char first_three[4];
  
  char standard_file[45] = "index.html"; 	/* Standard file */
  char requested_file[45];  // Create a new buffer for requested file
  char oldfile[45];
  
  // loop to wait for requests and answer them
  while (1) {
    // Accept connections
    client_socket = accept(server_socket, 0, 0);
    if (client_socket == -1) {
      perror("client_socket");
      close(server_socket);
      close(client_socket);
      exit(1);
    }
    // Receive data from client socket
    if (recv(client_socket, client_buffer, 65536, MSG_CMSG_CLOEXEC) == -1){
      continue;
    }
    if (client_buffer == NULL) {
      continue;
    }
    
    // Extract filename
    char *error = NULL;
    file = substring(client_buffer, 5, ' ', &error);
    if (file == NULL) {
      continue;
    }
    

    strncpy(first_three, client_buffer, 3);
    first_three[3] = '\0'; // Null terminator
    if (strcmp(first_three, "GET") != 0)
      {
q	// continue the loop if the first three characters are not "GET"
	continue;
      }
    if (strcmp(file, oldfile) == 0) {
      continue;
    }
    if (strcmp(file, "") != 0) {
      strncpy(requested_file, standard_file, sizeof(requested_file) -1);
    } 
    // OPEN file
    open_fd = open(file, O_RDONLY);
    if (open_fd == -1 && strcmp(file, "") == 0) {
      if (errno == ENOENT) {
	// File not found, send 404
	dprintf(client_socket, "HTTP/1.1 404 Not Found\r\nContent-Type: text/plain\r\n\r\nFile not found.\n");
	close(client_socket);
	continue;
      } else {
	// Other error, send 500
	perror("open");
	dprintf(client_socket, "HTTP/1.1 500 Internal Server Error\r\n\r\n");
	close(client_socket);
	continue;
      }
      close(client_socket);
      continue;
    } else if (open_fd == -1) {
      // Other error handling for actual file errors
      perror("open");
      close(client_socket);
      // ... handle error
      // for now ...
      continue;
    }
    int file_size = lseek(open_fd, 0, SEEK_END);  // Get file size
    lseek(open_fd, 0, SEEK_SET);  // Reset file pointer
    
    // Send response header
    dprintf(client_socket, "HTTP/1.1 200 OK\r\nContent-Type: text/html ; charset=utf-8\r\nContent-Length: %d\r\n\r\n", file_size);

    sendfile(client_socket, open_fd, 0, 65536);
    if (strcmp(requested_file, "") == 0){
      strcpy(oldfile, standard_file);
	} else {
      if (strcmp(file, oldfile) == 0) {
	// No change in requested file, keep oldfile as it is
      } else {
	strcpy(oldfile, requested_file);  // Update oldfile with the new requested filename
      }

    }
    close(open_fd);
    close(client_socket);
    
  }
}

/* Local Variables: */
/* jinx-languages: "en_US" */
/* End: */
