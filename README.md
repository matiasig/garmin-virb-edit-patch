# Parche para Garmin VIRB Edit 5.4.3 (Mapa y Sincronización GPS G-Metrix)

Reparación completa para la aplicación de escritorio **Garmin VIRB Edit v5.4.3** en Windows 10/11, solucionando la pantalla en blanco en **Sincronización GPS**, los errores de script del navegador embebido (`WebBrowser`) y el fallo que impedía guardar el tramo sincronizado del recorrido GPS.

---

## Problemas Solucionados

1. **Pantalla en blanco en "Sincronización GPS"**:
   - Garmin VIRB Edit 5.4.3 intentaba cargar `file:///.../GoogleMaps/maps.html` usando la antigua API v3 de Google Maps sin API Key dentro de un control `System.Windows.Controls.WebBrowser` (IE7/IE11), además de verificar conectividad contra servidores obsoletos.
   - **Solución**: Se parcheó el código IL de `VirbEdit.exe` (`AppState_t`, `MapControl_t`, `SimpleWebBrowser_t`) para inyectar mediante `NavigateToString` un motor de mapas HTML5 Canvas autónomo (`maps.html`) compatible con IE11 (`X-UA-Compatible: IE=edge`), con soporte para capas de **Mapa**, **Satélite** y **OpenStreetMap (OSM)** sin necesidad de API Key.
2. **Error de script (`No se puede obtener la propiedad 'visible' de referencia nula o sin definir`)**:
   - **Solución**: Se implementaron todas las funciones de la interfaz `MapControl_t` / `JsTrackInterface` (`SetTrack`, `AddTrack`, `SetTrackSegment`, `ClearTrackSegment`, `SetMarkerPosition`, `HideMarker`, `MapDidInitialize`, `GetClosestPositionOnTrack`, `DragStartHandler`, `DragEndHandler`) y se suprimieron los diálogos de error de script.
3. **Reinicio del tramo GPS al inicio (`0:00:00`) al editar o guardar**:
   - Durante el arrastre en el mapa o en el deslizador, `IsDraggingMapView()` y `mIsDraggingMapSlider` bloqueaban la ejecución de `UpdatePolyline()`, y el temporizador interno borraba `mTempPosition` antes de soltar el clic (`MapViewDragCompleted`), dejando `mAbsoluteStartTime` y el segmento del clip en `0:00:00`.
   - **Solución**: Se parchearon `AlignTrackViewModelBase_t::IsDraggingMapView`, `MapViewPositionChanged`, `MapViewDragStarted`, `AlignTrackPlayerViewModel_t::MapSliderDragStarted` y `DataStartPickerViewModel_t::OffsetSliderDragStarted` para actualizar `CurrentTelemetryOffset`, `mAbsoluteStartTime` y `UpdatePolyline()` en tiempo real.

---

## Instalación Rápida

1. Instala **Garmin VIRB Edit 5.4.3** normalmente (si aún no lo tienes instalado).
2. Cierra Garmin VIRB Edit.
3. Haz clic derecho sobre **`Aplicar_Parche_Garmin_VIRB.bat`** y selecciona **"Ejecutar como administrador"**.
   - El script creará automáticamente una copia de respaldo (`VirbEdit.exe.bak`) y copiará los archivos parcheados desde `Parche_Archivos/` hacia `C:\Program Files\Garmin\VIRB Edit` (o `C:\Program Files (x86)\Garmin\VIRB Edit`).

---

## Contenido del Repositorio

- `Aplicar_Parche_Garmin_VIRB.bat`: Instalador automático del parche con respaldo del ejecutable original.
- `Parche_Archivos/`:
  - `VirbEdit.exe`: Ejecutable de Garmin VIRB Edit 5.4.3 parcheado.
  - `VirbEdit.exe.config`: Configuración actualizada para evitar bloqueos de autodetección de códecs al iniciar.
  - `maps.html`: Motor interactivo de mapas HTML5 Canvas para sincronización de rutas G-Metrix.
- `patch_virb_edit.ps1`: Script en PowerShell que aplica de forma reproducible los parches binarios IL sobre el `VirbEdit.exe` original.
