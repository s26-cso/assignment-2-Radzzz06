/*
    We build the library filename: "libop.so",We LOAD that .so file at runtime using dlopen(),We find the function inside it using dlsym()
    We CALL that function with the operands, and print the output.We UNLOAD the library using dlclose() to free memory
    This repeat forever until EOF

    dlopen() lets us load a .so file while the program is running.
    dlsym() then finds a specific function inside that loaded library.
*/

#include <stdio.h>   
#include <dlfcn.h>    // dlopen, dlsym, dlclose, dlerror
#include <string.h>   
#include <stdlib.h>   

int main() 
{

    char op[6];          // 5 chars max for op name + 1 for '\0'
    char libname[20];    // "lib" + 5 chars + ".so" + '\0'
    int num1,num2;

    // We define a function pointer type for this

    typedef int (*operation_func)(int, int);

    /*
      MAIN LOOP: keep reading input until EOF
     We expect 3 items: the op string, num1, num2, if it returns anything other than 3, we stop.
     */

    while (scanf("%5s %d %d", op, &num1, &num2) == 3) 
    {
        //Building the library filename
        snprintf(libname, sizeof(libname), "./lib%s.so", op);

        //dlopen() gives "loaded_library", a pointer to the loaded library or NULL if it failed

        void *loaded_library = dlopen(libname, RTLD_NOW | RTLD_LOCAL);

        // Check if loading failed
        if (loaded_library == NULL) 
        {       
            fprintf(stderr, "Error loading library '%s': %s\n", libname, dlerror());
            continue;   //skip this iteration, go read the next input 
        }


        dlerror();  //to clear any error that was present
        void *function_pointer = dlsym(loaded_library, op);

        //Check if finding the function failed 
        if (function_pointer == NULL) {
            fprintf(stderr, "Error finding function '%s' in '%s': %s\n",op, libname, dlerror());
            dlclose(loaded_library);        // still unload even on error 
            continue;
        }

        //Convert the pointer to a function
        
        operation_func operation = (operation_func) function_pointer;

        //calling the function, library handles it all

        int output = operation(num1, num2);
        printf("%d\n", output);

        /*
        UNLOAD the library to free memory,if we didn't do this,we'd run out of memory
        dlclose() unloads the library from our process memory
         */
        
        dlclose(loaded_library);

    }
    return 0;
}
