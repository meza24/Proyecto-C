#include "stb_image.h"
#include "stb_image_write.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <getopt.h>

int main(int argc, char *argv[]) {
    char nombreArchivoEntrada[100];
    const char *nombreArchivoSalida = NULL;
    int convertToJPEG = 0;
    int convertToPNG = 0;
    int opcion = 0;

    int c;

    while ((c = getopt(argc, argv, "hi:o:jp")) != -1) {
        switch (c) {
            case 'h':
                printf("Opciones:\n");
                printf("-h: Opción de ayuda\n");
                printf("-i [nombreArchivoEntrada]: Indicar path de imagen a ingresar\n");
                printf("-o [nombreArchivoSalida]: Indicar path de imagen de salida\n");
                printf("-j: Convertir a escala de grises en formato JPEG\n");
                printf("-p: Convertir a escala de grises en formato PNG\n");
                return 0;
            case 'i':
                strcpy(nombreArchivoEntrada, optarg);
                break;
            case 'o':
                nombreArchivoSalida = optarg;
                break;
            case 'j':
                convertToJPEG = 1;
                break;
            case 'p':
                convertToPNG = 1;
                break;
            case '?':
                fprintf(stderr, "Uso: %s -i [nombreArchivoEntrada] -o [nombreArchivoSalida] [-j | -p]\n", argv[0]);
                return 1;
        }
    }

    if (nombreArchivoSalida == NULL) {
        printf("Debe especificar un nombre de archivo de salida con -o.\n");
        return 1;
    }

    int esJpg = 0;
    int esPng = 0;
    char *ext = strrchr(nombreArchivoEntrada, '.');
    if (ext) {
        if (strcmp(ext, ".jpg") == 0 || strcmp(ext, ".jpeg") == 0) {
            esJpg = 1;
        } else if (strcmp(ext, ".png") == 0) {
            esPng = 1;
        }
    }

    if (!esJpg && !esPng) {
        printf("El tipo de imagen no es compatible.\n");
        return 1;
    }

    int ancho, alto, canales;
    unsigned char *datosImagen = stbi_load(nombreArchivoEntrada, &ancho, &alto, &canales, 0);

    if (!datosImagen) {
        printf("Se ha producido un error al cargar la imagen de origen.\n");
        return 1;
    }

    int nuevoAncho, nuevoAlto, nuevosCanales;
    unsigned char *datosImagenRotada = NULL;

    if (opcion >= 1 && opcion <= 3) {
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

        datosImagenRotada = (unsigned char *)malloc(nuevoAncho * nuevoAlto * nuevosCanales);

        if (!datosImagenRotada) {
            printf("Se ha producido un fallo al asignar memoria para la imagen que se encuentra en proceso de rotación.\n");
            return 1;
        }

        for (int y = 0; y < alto; y++) {
            for (int x = 0; x < ancho; x++) {
                for (int c = 0; c < canales; c++) {
                    if (opcion == 1) {
                        datosImagenRotada[(x * nuevoAncho + (nuevoAncho - y - 1)) * canales + c] = datosImagen[(y * ancho + x) * canales + c];
                    } else if (opcion == 2) {
                        datosImagenRotada[((nuevoAncho - x - 1) * nuevoAlto + y) * canales + c] = datosImagen[(y * ancho + x) * canales + c];
                    } else if (opcion == 3) {
                        datosImagenRotada[((nuevoAlto - y - 1) * nuevoAncho + (nuevoAncho - x - 1)) * canales + c] = datosImagen[(y * ancho + x) * canales + c];
                    }
                }
            }
        }

        if (convertToJPEG) {
            stbi_write_jpg(nombreArchivoSalida, nuevoAncho, nuevoAlto, nuevosCanales, datosImagenRotada, 100);
        } else if (convertToPNG) {
            stbi_write_png(nombreArchivoSalida, nuevoAncho, nuevoAlto, nuevosCanales, datosImagenRotada, nuevoAncho * nuevosCanales);
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
