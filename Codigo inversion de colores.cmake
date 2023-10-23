#include <stdio.h>
#include <stdlib.h>
#include <png.h>
#include <jpeglib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>  // pa manejo de errores
#include <getopt.h>


//  lit es pa cargar y guardar las imagenes PNG
void load_png(const char *filename, unsigned char **image, int *width, int *height) {
    FILE *fp = fopen(filename, "rb");
    if (!fp) {
        fprintf(stderr, "No se pudo abrir el archivo.\n");
        exit(1);
    }
    
    png_structp png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    png_infop info_ptr = png_create_info_struct(png_ptr);
    
    png_init_io(png_ptr, fp);
    png_read_info(png_ptr, info_ptr);
    
    *width = png_get_image_width(png_ptr, info_ptr);
    *height = png_get_image_height(png_ptr, info_ptr);
    
    png_bytepp rows = (png_bytepp) malloc(sizeof(png_bytep) * (*height));
    for (int y = 0; y < (*height); y++) char *buffer = malloc(256);
if (buffer == NULL) {
    perror("Falló la asignación de memoria");
    exit(EXIT_FAILURE);
}{
        rows[y] = (png_bytep) malloc(png_get_rowbytes(png_ptr, info_ptr));
char *buffer = malloc(256);
if (buffer == NULL) {
    perror("Falló la asignación de memoria");
    exit(EXIT_FAILURE);
}
    }
    
    png_read_image(png_ptr, rows);
    
    *image = (unsigned char *) malloc((*width) * (*height) * 3);
    for (int y = 0; y < (*height); y++) {
        for (int x = 0; x < (*width); x++) {
            png_bytep px = &(rows[y][x * 4]);
            (*image)[(y * (*width) + x) * 3] = px[0];
            (*image)[(y * (*width) + x) * 3 + 1] = px[1];
            (*image)[(y * (*width) + x) * 3 + 2] = px[2];
        }
char *buffer = malloc(256); 
if (buffer == NULL) {
    perror("Falló la asignación de memoria");
    exit(EXIT_FAILURE);
}
        free(rows[y]);
    }
    
    free(rows);
    fclose(fp);
    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
}

// Guarda las imágenes PNG
void save_png(const char *filename, unsigned char *image, int width, int height) {
    FILE *fp = fopen(filename, "wb");
    if (!fp) {
        fprintf(stderr, "No se pudo abrir el archivo.\n");
        exit(1);
    }
    
    png_structp png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    png_infop info_ptr = png_create_info_struct(png_ptr);
    
    png_init_io(png_ptr, fp);
    png_set_IHDR(png_ptr, info_ptr, width, height, 8, PNG_COLOR_TYPE_RGB, PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);
    png_write_info(png_ptr, info_ptr);
    
    png_bytepp rows = (png_bytepp) malloc(sizeof(png_bytep) * height);
    for (int y = 0; y < height; y++)char *buffer = malloc(256);
if (buffer == NULL) {
    perror("Falló la asignación de memoria");
    exit(EXIT_FAILURE);
} {
        rows[y] = (png_bytep) malloc(png_get_rowbytes(png_ptr, info_ptr));
        for (int x = 0; x < width; x++) {
            png_bytep px = &(rows[y][x * 3]);
            px[0] = image[(y * width + x) * 3];
            px[1] = image[(y * width + x) * 3 + 1];
            px[2] = image[(y * width + x) * 3 + 2];
        }
char *buffer = malloc(256);
if (buffer == NULL) {
    perror("Falló la asignación de memoria");
    exit(EXIT_FAILURE);
}
    }
    
    png_write_image(png_ptr, rows);
    png_write_end(png_ptr, NULL);
    
    for (int y = 0; y < height; y++) {
        free(rows[y]);
    }
    free(rows);
    fclose(fp);
    png_destroy_write_struct(&png_ptr, &info_ptr);
}
//hasta aquí llega png

//comienza jpeg, lo mismo pero para imagenes jpeg
void load_jpeg(const char *filename, unsigned char **image, int *width, int *height) {
    FILE *infile;
    struct jpeg_decompress_struct cinfo;
    struct jpeg_error_mgr jerr;
    
    cinfo.err = jpeg_std_error(&jerr);
    jpeg_create_decompress(&cinfo);
    
    if ((infile = fopen(filename, "rb")) == NULL) {
        fprintf(stderr, "Error al abrir archivo JPEG %s\n", filename);
        exit(1);
    }
    
    jpeg_stdio_src(&cinfo, infile);
    jpeg_read_header(&cinfo, TRUE);
    jpeg_start_decompress(&cinfo);
    
    *width = cinfo.output_width;
    *height = cinfo.output_height;
    *image = (unsigned char*)malloc((*width) * (*height) * 3);
char *buffer = malloc(256);
if (buffer == NULL) {
    perror("Falló la asignación de memoria");
    exit(EXIT_FAILURE);
}
    
    JSAMPARRAY buffer;
    buffer = (*cinfo.mem->alloc_sarray)((j_common_ptr)&cinfo, JPOOL_IMAGE, (*width) * 3, 1);
    
    while (cinfo.output_scanline < cinfo.output_height) {
        jpeg_read_scanlines(&cinfo, buffer, 1);
        for (int x = 0; x < *width; x++) {
            (*image)[(cinfo.output_scanline - 1) * (*width) * 3 + x * 3 + 0] = buffer[0][x * 3 + 0];
            (*image)[(cinfo.output_scanline - 1) * (*width) * 3 + x * 3 + 1] = buffer[0][x * 3 + 1];
            (*image)[(cinfo.output_scanline - 1) * (*width) * 3 + x * 3 + 2] = buffer[0][x * 3 + 2];
        }
    }
    
    jpeg_finish_decompress(&cinfo);
    jpeg_destroy_decompress(&cinfo);
    fclose(infile);
}
// las guarda xd
void save_jpeg(const char *filename, unsigned char *image, int width, int height) {
    struct jpeg_compress_struct cinfo;
    struct jpeg_error_mgr jerr;
    
    FILE * outfile;
    JSAMPROW row_pointer[1];
    
    cinfo.err = jpeg_std_error(&jerr);
    jpeg_create_compress(&cinfo);
    
    if ((outfile = fopen(filename, "wb")) == NULL) {
        fprintf(stderr, "Error al abrir archivo JPEG %s\n", filename);
        exit(1);
    }
    
    jpeg_stdio_dest(&cinfo, outfile);
    cinfo.image_width = width;
    cinfo.image_height = height;
    cinfo.input_components = 3;
    cinfo.in_color_space = JCS_RGB;
    
    jpeg_set_defaults(&cinfo);
    jpeg_set_quality(&cinfo, 75, TRUE);
    jpeg_start_compress(&cinfo, TRUE);
    
    while (cinfo.next_scanline < cinfo.image_height) {
        row_pointer[0] = &image[cinfo.next_scanline * width * 3];
        jpeg_write_scanlines(&cinfo, row_pointer, 1);
    }
    
    jpeg_finish_compress(&cinfo);
    fclose(outfile);
    jpeg_destroy_compress(&cinfo);
}
//aquí termina jpeg

// todo lo anterior con las biblotecas que dio la profre y deay es algo que obviamente saque de internet por que ajá, easy

void invert_colors(unsigned char *image, int width, int height) {//basicamente es una función bucle para recoger cada pixel R,G ó B de la imagen y "girar" un dial pa cambiar su color, easy, el maximo es de 255. Porblemas: solo sirve pa imagenes RGB pero trol cualquier otro tipo de gama de colores xd
    for(int i = 0; i < height; i++) {
        for(int j = 0; j < width; j++) {
            int index = (i * width + j) * 3;
            image[index] = 255 - image[index];      // Inversión de R
            image[index + 1] = 255 - image[index + 1]; // Inversión de G
            image[index + 2] = 255 - image[index + 2]; // Inversión de B
        }
    }
}
//mainnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn
//funcion main donde se hace la magia y se llama todas las funciones
int main(int argc, char *argv[]) {
    int opt;
    char *input_path = NULL;
    char *output_path = NULL;
    unsigned char *image;
    int width, height;
    int flag = 0; // 0 para PNG, 1 para JPEG

    // esto es para definir la ruta de entrada, la de salida y el error que es "h", o sea el analisis de argumentos xd
    while ((opt = getopt(argc, argv, "hi:o:jp")) != -1) {
        switch (opt) {
            case 'h':
                 printf("Opciones:\n");
                printf("-h: Opción de ayuda\n");
                printf("-i [input_path]: Indicar path de imagen a ingresar\n");
                printf("-o [output_path]: Indicar path de imagen de salida\n");
                printf("-j: Invierte los colores y guarda en formato JPEG\n");
                printf("-p: Invierte los colores y guarda en formato PNG\n");
                return 0;
            case 'i':
                input_path = optarg;
                break;
            case 'o':
                output_path = optarg;
                break;
            case 'j':
                convertToJPEG = 1;
                break;
            case 'p':
                convertToPNG = 1;
                break;
            default:
                fprintf(stderr, "Opción no reconocida.\n");
                exit(EXIT_FAILURE);
        }
    }

    if (input_path == NULL || output_path == NULL) {
        fprintf(stderr, "Las opciones -i y -o son requeridas.\n");
        exit(EXIT_FAILURE);
    }

    // esto sirve pa ver si el archivo es correcto, o sea si es una imagen PNG ó JPEG y RGB
    if (strstr(input_path, ".png") != NULL) {
        load_png(input_path, &image, &width, &height);
        flag = 0;
    } else if (strstr(input_path, ".jpg") != NULL || strstr(input_path, ".jpeg") != NULL) {
        load_jpeg(input_path, &image, &width, &height);
        flag = 1;
    } else {
        fprintf(stderr, "Formato no soportado.\n");
        exit(EXIT_FAILURE);
    }

    // invierta la vara xd
    invert_colors(image, width, height);

    // guarda la imagen ya cambiada o invertida
    if (flag == 0) {
        save_png(output_path, image, width, height);
    } else {
        save_jpeg(output_path, image, width, height);
    }

    // Libera memoria, cutre xd
    free(image);

    return 0;
}
