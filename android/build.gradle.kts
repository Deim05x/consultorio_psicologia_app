import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

// Plugins aplicados de forma global (pero sin activar en este nivel)
plugins {
    id("com.google.gms.google-services") version "4.3.15" apply false
    // Aquí puedes agregar otros plugins si los necesitas
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Ya no necesitas classpath aquí para com.google.gms si ya lo declaraste en plugins
        // classpath("com.google.gms:google-services:4.3.15") ❌ innecesario si usas plugins {}
    }
}

// Configuración de repositorios para todos los proyectos
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Cambiar directorio de compilación
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

// Tarea para limpiar el proyecto
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
