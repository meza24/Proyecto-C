#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image.h"
#include "stb_image_write.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
    //Declaramos un array para almacenar el nombre de la imagen
    char nombreArchivoEntrada[100]; 
    const char* nombreArchivoSalida;

    printf("Introduzca el nombre del archivo de imagen de origen: ");
    scanf("%s", nombreArchivoEntrada);

    int esJpg = 0;
    int esPng = 0;

    // Verificamos el tipo de imagen de entrada (JPG o PNG)
    char* ext = strrchr(nombreArchivoEntrada, '.');
    if (ext) {
        if (strcmp(ext, ".jpg") == 0 || strcmp(ext, ".jpeg") == 0) {
            esJpg = 1; // Es tipo JPG
        } else if (strcmp(ext, ".png") == 0) {
            esPng = 1; // Es tipo PNG
        }
    }

    if (esJpg) {
        printf("Seleccione una de las siguientes opciónes:\n");
        printf("1. Rotar la imagen JPG 90 grados en dirección de las agujas del reloj.\n");
        printf("2. Rotar la imagen JPG 90 grados en sentido contrario a las agujas del reloj.\n");
        printf("3. Rotar la imagen JPG 180 grados.\n");
        nombreArchivoSalida = "salida.jpg";
    } else if (esPng) {
        printf("Seleccione una de las siguientes opciónes:\n");
        printf("1. Rotar la imagen PNG 90 grados en dirección de las agujas del reloj.\n");
        printf("2. Rotar la imagen PNG 90 grados en sentido contrario a las agujas del reloj.\n");
        printf("3. Rotar la imagen PNG 180 grados.\n");
        nombreArchivoSalida = "salida.png";
    } else {
        printf("El tipo de imagen no es commpatible.\n");
        return 1;
    }

    int ancho, alto, canales;
    unsigned char* datosImagen = stbi_load(nombreArchivoEntrada, &ancho, &alto, &canales, 0);

    if (!datosImagen) {
        printf("Se ha producido un error al cargar la imagen de origen.\n");
        return 1;
    }

    int opcion;
    scanf("%d", &opcion);

    int nuevoAncho, nuevoAlto, nuevosCanales;
    unsigned char* datosImagenRotada = NULL;

    if (opcion == 1 || opcion == 2 || opcion == 3) {
        if (opcion == 1) {
            nuevoAncho = alto;
            nuevoAlto = ancho;
            nuevosCanales = canales;
        } else if (opcion == 2) {
            nuevoAncho = alto;
            nuevoAlto = ancho;
            nuevosCanales = canales;
        } else if (opcion == 3) {
            nuevoAncho = ancho;
            nuevoAlto = alto;
            nuevosCanales = canales;
        }

        datosImagenRotada = (unsigned char*)malloc(nuevoAncho * nuevoAlto * nuevosCanales);

        if (!datosImagenRotada) {
            printf("Se ha producido un fallo al asignar memoria para la imagen que se encuentra en proceso de rotación.\n");
            return 1;
        }

        for (int y = 0; y < alto; y++) {
            for (int x = 0; x < ancho; x++) {
                for (int c = 0; c < canales; c++) {
                    if (opcion == 1) {
                        // Realiza una rotación de 90 grados en sentido horario.
                        datosImagenRotada[(x * nuevoAncho + (nuevoAncho - y - 1)) * canales + c] = datosImagen[(y * ancho + x) * canales + c];
                    } else if (opcion == 2) {
                        // Realiza una rotación de 90 grados en sentido antihorario.
                        datosImagenRotada[((nuevoAncho - x - 1) * nuevoAlto + y) * canales + c] = datosImagen[(y * ancho + x) * canales + c];
                    } else if (opcion == 3) {
                        // Realiza una rotación de 180 grados.
                        datosImagenRotada[((nuevoAlto - y - 1) * nuevoAncho + (nuevoAncho - x - 1)) * canales + c] = datosImagen[(y * ancho + x) * canales + c];
                    }
                }
            }
        }

        if (opcion >= 1 && opcion <= 3) {
            if (esJpg) {
                stbi_write_jpg(nombreArchivoSalida, nuevoAncho, nuevoAlto, nuevosCanales, datosImagenRotada, 100);
            } else if (esPng) {
                stbi_write_png(nombreArchivoSalida, nuevoAncho, nuevoAlto, nuevosCanales, datosImagenRotada, nuevoAncho * nuevosCanales);
            }
        }
    } else {
        printf("Opción no válida.\n");
        return 1;
    }

    stbi_image_free(datosImagen);
    free(datosImagenRotada);

    printf("La imagen ha sido rotada con éxito y se ha guardado como: %s.\n", nombreArchivoSalida);

    return 0;
}
