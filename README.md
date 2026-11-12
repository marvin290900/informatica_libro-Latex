# Libro Técnico de Informática (Plantilla LaTeX Interactiva)

Proyecto editorial desarrollado en **LuaLaTeX** en formato horizontal (*landscape*) con menú lateral interactivo de navegación por secciones, portadillas personalizadas y flujo automatizado de importación desde documentos de Microsoft Word (`.docx`).

---

## 1. Requisitos e Instalación Local (Ubuntu / Debian)

### 1.1. Paquetes del sistema, motor LaTeX y herramientas de conversión
Ejecuta el siguiente comando en la terminal para instalar TeX Live completo (incluye `lualatex`, `fontspec`, `tikz`, `eso-pic` y `fancyhdr`), `pandoc` para conversión de documentos y utilidades de fuentes:

```bash
sudo apt update
sudo apt install -y texlive-full pandoc fontconfig wget unzip
```

### 1.2. Instalación de tipografías requeridas
El diseño utiliza **Arial / Liberation Sans** para el cuerpo de texto y **Gothic A1** para los números de portadilla:

```bash
# Instalar Liberation Sans (métricamente idéntica a Arial en Linux)
sudo apt install -y fonts-liberation

# Descargar e instalar Gothic A1 (Bold y Black)
mkdir -p ~/.local/share/fonts
wget -q [https://github.com/google/fonts/raw/main/ofl/gothica1/GothicA1-Bold.ttf](https://github.com/google/fonts/raw/main/ofl/gothica1/GothicA1-Bold.ttf) -P ~/.local/share/fonts/
wget -q [https://github.com/google/fonts/raw/main/ofl/gothica1/GothicA1-Black.ttf](https://github.com/google/fonts/raw/main/ofl/gothica1/GothicA1-Black.ttf) -P ~/.local/share/fonts/

# Actualizar caché de fuentes y verificar instalación
fc-cache -fv
fc-list : family style | grep -i "Gothic A1"
```

---

## 2. Configuración del Entorno en Visual Studio Code

1. Instala **Visual Studio Code**.
2. Instala la extensión oficial **LaTeX Workshop** (`James-Yu.latex-workshop`).
3. Configura **LuaLaTeX** como compilador predeterminado en VS Code (`Ctrl + ,` -> abrir `settings.json`) para soportar `fontspec` y las fuentes del sistema:

```json
{
    "latex-workshop.latex.tools": [
        {
            "name": "lualatex",
            "command": "lualatex",
            "args": [
                "-synctex=1",
                "-interaction=nonstopmode",
                "-file-line-error",
                "%DOC%"
            ]
        }
    ],
    "latex-workshop.latex.recipes": [
        {
            "name": "lualatex x2",
            "tools": [
                "lualatex",
                "lualatex"
            ]
        }
    ]
}
```

---

## 3. Flujo de Trabajo: Convertir Word (`.docx`) a LaTeX y Extraer Imágenes

Para importar capítulos redactados en Word sin perder estructura ni imágenes:

### 3.1. Convertir `.docx` a `.tex` y extraer recursos multimedia
Ejecuta `pandoc` indicando la carpeta donde se extraerán las imágenes (`--extract-media`):

```bash
pandoc ruta/al/documento.docx \
  -f docx \
  -t latex \
  --extract-media=imagenes/capitulo_x \
  -o contenido/parte_x.tex
```

* Pandoc creará automáticamente la subcarpeta `imagenes/capitulo_x/media/` con todas las imágenes incrustadas en el Word.
* En el archivo `.tex` generado, verifica que las rutas en `\includegraphics{...}` coincidan con la ubicación relativa desde `main.tex` y ajusta el ancho recomendado (por ejemplo, `\includegraphics[width=0.85\textwidth]{...}`).

---

## 4. Generación del PDF Final

### Opción A: Desde la terminal (Compilación doble recomendada)
Para que los hipervínculos del menú lateral, los marcadores del PDF y la numeración de páginas se calculen correctamente, ejecuta **dos pasadas consecutivas** de `lualatex`:

```bash
lualatex -interaction=nonstopmode main.tex && lualatex -interaction=nonstopmode main.tex
```

El archivo final se generará en la raíz del proyecto como **`main.pdf`**.

### Opción B: Desde VS Code
Abre `main.tex` y presiona **`Ctrl + Alt + B`** (ejecutará la receta `lualatex x2` configurada).

---

## 5. Estructura del Proyecto

```text
libro_ACC/
├── main.tex              # Archivo maestro del documento
├── config/
│   └── diseno.tex        # Geometría, tipografía, menú lateral interactivo y portadillas
├── contenido/            # Archivos .tex individuales de cada una de las 10 partes
├── imagenes/             # Recursos gráficos e imágenes extraídas
├── .gitignore            # Exclusión de archivos temporales de compilación
└── README.md             # Documentación del proyecto
```