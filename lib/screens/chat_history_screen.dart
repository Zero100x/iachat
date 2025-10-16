import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart'; // ✅ Necesario para seleccionar archivos

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<FileObject> files = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  /// 🔹 Carga los archivos de historial del usuario actual
  Future<void> _loadFiles() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response =
          await supabase.storage.from('chat_histories').list(path: user.id);

      setState(() {
        files = response;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error loading files: $e");
      setState(() => loading = false);
    }
  }

  /// 🔹 Descarga un archivo de historial
  Future<void> _downloadFile(String path, String name) async {
    try {
      final data = await supabase.storage.from('chat_histories').download(path);

      // Aquí podrías guardar localmente el archivo con path_provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archivo descargado: $name')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar: $e')),
      );
    }
  }

  /// 🔹 Sube un nuevo archivo al bucket de Supabase
  Future<void> _uploadFile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final picker = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
        withData: true, // ✅ asegura que se obtengan los bytes
      );

      if (picker != null && picker.files.isNotEmpty) {
        final file = picker.files.first;
        final bytes = file.bytes!;
        final fileName = file.name;

        await supabase.storage
            .from('chat_histories')
            .uploadBinary('${user.id}/$fileName', bytes);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Historial subido exitosamente')),
        );

        _loadFiles();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al subir archivo: $e')),
      );
    }
  }

  /// 🔹 Carga archivos de otro usuario (por ID)
  Future<void> _loadFromOtherUser(String otherUserId) async {
    try {
      final response =
          await supabase.storage.from('chat_histories').list(path: otherUserId);
      setState(() => files = response);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Historial cargado de otra cuenta')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando historial: $e')),
      );
    }
  }

  /// 🔹 Interfaz principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Chats"),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _uploadFile,
            tooltip: "Subir historial",
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFiles,
            tooltip: "Actualizar lista",
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : files.isEmpty
              ? const Center(child: Text("No hay historiales guardados"))
              : ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return ListTile(
                      title: Text(file.name),
                      leading: const Icon(Icons.chat_bubble_outline),
                      trailing: IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () => _downloadFile(
                          '${supabase.auth.currentUser!.id}/${file.name}',
                          file.name,
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.account_circle),
        label: const Text("Cargar de otra cuenta"),
        onPressed: () async {
          final controller = TextEditingController();
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Cargar historial de otra cuenta"),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: "ID de usuario",
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _loadFromOtherUser(controller.text.trim());
                  },
                  child: const Text("Cargar"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
