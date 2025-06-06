#include <stdio.h>
#include <stdlib.h>

// Function to return a substring from pos to the first occurrence of char or the end
char* substring(const char *buffer, int pos, char c, char **error) {
    // Check if pos is greater than the length of the buffer
    int buffer_length = 0;
    const char *ptr = buffer;
    while (*ptr++) {
        buffer_length++;
    }
    if (pos >= buffer_length) {
        *error = "Position is greater than the length of the buffer";
        return NULL;
    }

    // Find the index of the first occurrence of char after pos
    int index = pos;
    while (buffer[index] != '\0' && buffer[index] != c) {
        index++;
    }

    // Allocate memory for the substring
    char *substring = (char*)malloc((index - pos + 1) * sizeof(char));
    if (substring == NULL) {
        *error = "Memory allocation failed";
        return NULL;
    }

    // Copy the substring into the allocated memory
    int i;
    for (i = pos; i < index; i++) {
        substring[i - pos] = buffer[i];
    }
    substring[i - pos] = '\0';  // Null-terminate the substring

    return substring;
}

int main() {
    const char *buffer = "Hello, World!";
    int pos = 3;  // Starting position
    char c = ' '; // Character to search for
    char *error = NULL;

    char *result = substring(buffer, pos, c, &error);
    if (result == NULL) {
        printf("Error: %s\n", error);
    } else {
        printf("Substring: %s\n", result);
        free(result);  // Free allocated memory
    }

    return 0;
}
