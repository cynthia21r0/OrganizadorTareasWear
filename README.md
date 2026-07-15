# HomeTasks Wear

Vista de reloj (Wear OS) de HomeTasks, con las 4 pantallas del diseño:
lista de tareas → detalle → iniciando → completada.

## 1. Crear el proyecto real

Estos archivos son el contenido de `lib/` + `pubspec.yaml`. Para tener
un proyecto Flutter completo (con carpetas `android/`, `ios/`, etc.):

```bash
flutter create tareas_wear
```

Luego reemplaza la carpeta `lib/` generada y el `pubspec.yaml` por los
archivos de esta entrega, y corre:

```bash
flutter pub get
```

## 2. Configurar `android/app/src/main/AndroidManifest.xml` para Wear OS

Agrega dentro de `<manifest>`, antes de `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-feature android:name="android.hardware.type.watch" />
```

Y dentro de `<application>`, antes de `<activity>`:

```xml
<meta-data
    android:name="com.google.android.wearable.standalone"
    android:value="true" />
```

`standalone = true` significa que la app puede correr aunque el reloj
no esté emparejado con un teléfono en ese momento (usa su propia
conexión a internet, WiFi o datos).

## 3. Probar en emulador

Android Studio → AVD Manager → Create Device → categoría "Wear OS" →
elige una imagen de sistema (Wear OS 4 o superior recomendado) → Finish.

```bash
flutter run -d <id-del-emulador-wear>
```

## 4. Cómo probar HOY MISMO sin reloj físico

El proyecto ya viene con datos de ejemplo en `main.dart` (las mismas
3 tareas de tu mockup), así que puedes correrlo directo en un emulador
de teléfono normal para revisar el diseño:

```bash
flutter run
```

Verás la lista, y al tocar una tarea: detalle → Comenzar → Iniciando →
Completada → vuelve a la lista con el progreso actualizado (1/3).

## 5. Conectar con tu backend real

`lib/services/wear_task_repository.dart` ya apunta a:
```
https://organizadortareasback.onrender.com/api
```
usando las mismas rutas que tu app de teléfono
(`GET /tasks/user/:userId`, `PATCH /tasks/:id/toggle`).

Para usarlo en vez de los datos de ejemplo, en `main.dart` cambia:

```dart
home: TaskListScreen(
  userName: 'Sofía',
  initialTasks: const [...], // <- quitar esto
),
```

por una carga real vía `FutureBuilder`:

```dart
home: FutureBuilder<List<WearTask>>(
  future: WearTaskRepository().getMyTasks(WearApiClient.instance.userId!),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return TaskListScreen(userName: 'Sofía', initialTasks: snapshot.data!);
  },
),
```

## 6. El problema del login en el reloj

Escribir usuario/contraseña con teclado de reloj es mala experiencia.
Dos formas de resolverlo, de más simple a más robusta:

**A. Código de emparejamiento manual (rápido de implementar)**
Tu app de teléfono muestra un código de 6 dígitos temporal (endpoint
nuevo en tu backend que genera un código ligado al JWT del usuario).
El usuario lo teclea una sola vez en el reloj; el reloj lo cambia por
el JWT real llamando a tu API. Después de eso, el reloj guarda su
propio token igual que hace el teléfono.

**B. Wearable Data Layer API (transferencia automática por Bluetooth)**
El teléfono, ya logueado, envía el JWT directo al reloj vía Bluetooth
usando `MessageClient` de Google Play Services (requiere código nativo
Kotlin en ambos proyectos, o el paquete `flutter_to_wear`). Es más
elegante (cero fricción para el usuario) pero más trabajo de setup.

Para un proyecto académico/demo, la opción A es suficiente y mucho
más rápida de construir. Si quieres, en el siguiente paso te ayudo a
diseñar el endpoint de emparejamiento en tu NestJS backend.

## 7. Íconos de tareas

Ahora mismo `WearTask._iconForTitle()` usa una heurística simple por
palabras clave (cuarto → cama, deberes → libro, guitarra → nota
musical). Si más adelante quieres íconos ilustrados como los del
mockup original de Figma, expórtalos como PNG/SVG desde ahí y
reemplaza `Icon(task.icon)` por `Image.asset(...)` en las pantallas.
