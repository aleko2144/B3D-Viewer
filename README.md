# B3D-Viewer
Virtual World Inventor games (Hard Truck, King of The Road) *.b3d viewer powered by Godot 4.3 engine.

Утилита для просмотра b3d-файлов на движке Godot 4.3. Поддерживаются как ранние проекты SoftLab-NSK (MirDemo и т.п.), так и игра Дальнобойщики-2.
В основе проекта лежат наработки, в том числе, [Duude92](https://github.com/Duude92), [AlexKimov](https://github.com/AlexKimov), [Voron295](https://github.com/Voron295) и [LabVaKars](https://github.com/LabVaKars).

Проект написан, в основном, в 2023-м году. Код сырой и кривой, но в целом рабочий. Если кто решится доработать это - успехов:)

vk.com/rnr_mods

## Запуск:
1. Распаковать приложение в какую-нибудь папку приложение.
2. В viewer.ini задать параметр VWIVersion = 2, если планируется просмотр файлов игры "Дальнобойщики-2". В противном случае задать VWIVersion = 1.
3. В viewer.ini задать параметр scenes_file = "список_b3d.lst". Вместе с программой поставлются примеры списков (файлы scenes_d1.lst и scenes_d2.lst).
4. Если планируется просмотр b3d-файлов игры "Дальнобойщики-2", то первым делом нужно подгрузить файл common.b3d, а затем только всё остальное.
### Параметры lst-файла:
Загрузка одиночного файла: "scene: (path) (hide)", где (path) - путь к файлу, (hide) - скрыть сцену после импорта (только для common.b3d игры "Дальнобойщики-2").

Примеры: "scene: ./COMMON/COMMON.B3D : hide", "scene: ./MENV/dr.b3d"

Загрузка всех b3d-файлов из указанной директории: "dir: (path)", где (path) - путь к b3d-файлам.

Пример: "dir: ./ENV/"

## Управление:
### Разное:
1. F1 - спрятать/отобразить GUI
2. F2 - открыть меню просмотра списка объектов сцен
3. F3 - открыть меню взаимодействия с переключаемыми объектами
4. F4 - открыть меню переключения отображения объектов
5. F6 - снимок экрана
6. F10 - меню "о программе"
7. Ctrl+X - открыть меню выбора папки для сохранения всех импортированных сцен в формате gltf

### Переключение режимов отрисовки:
1. 1 - wireframe / normal (режим сетки)
2. 2 - unshaded  / normal (равносторонее освещение)

### Переключение фона:
1. 3 - текстура либо предзаданный цвет (если есть) / серый цвет / небо

### Переключение освещения:
1. 4 - вкл./выкл. фоновый источника света
2. L - вкл./выкл. фонарик

### Перемещение:
1. W/S - вперёд / назад
2. D/A - вправо / влево
3. E/Q - вверх  / вниз
4. ПКМ + движение мыши - обзор
5. Колёсико мыши вверх - увеличить скорость движения
6. Колёсико мыши вниз  - снизить скорость движения
7. R - сброс позиции
