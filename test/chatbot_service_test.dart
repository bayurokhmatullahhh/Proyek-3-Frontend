import 'package:flutter_test/flutter_test.dart';
import 'package:smart_urban_health/services/chatbot_service.dart';
import 'package:smart_urban_health/models/chat_message.dart';

/// ============================================================
/// UNIT TEST — ChatbotService & ChatMessage
/// Menguji: topic filtering, offline response, model integrity
/// ============================================================

void main() {
  // ──────────────────────────────────────────────────────────────
  // GROUP 1: ChatMessage Model Tests
  // ──────────────────────────────────────────────────────────────
  group('ChatMessage Model', () {
    test('factory user() harus membuat pesan dengan sender=user', () {
      final msg = ChatMessage.user('Halo');
      expect(msg.sender, MessageSender.user);
      expect(msg.text, 'Halo');
      expect(msg.isTyping, false);
    });

    test('factory bot() harus membuat pesan dengan sender=bot', () {
      final msg = ChatMessage.bot('Selamat datang');
      expect(msg.sender, MessageSender.bot);
      expect(msg.text, 'Selamat datang');
      expect(msg.isTyping, false);
    });

    test('factory typing() harus membuat typing indicator', () {
      final msg = ChatMessage.typing();
      expect(msg.sender, MessageSender.bot);
      expect(msg.isTyping, true);
      expect(msg.id, 'typing_indicator');
    });

    test('factory system() harus membuat system message', () {
      final msg = ChatMessage.system('Welcome');
      expect(msg.sender, MessageSender.system);
      expect(msg.text, 'Welcome');
    });

    test('copyWith harus menghasilkan salinan dengan field yang diubah', () {
      final msg = ChatMessage.user('original');
      final copied = msg.copyWith(text: 'modified');
      expect(copied.text, 'modified');
      expect(copied.sender, MessageSender.user);
      expect(copied.id, msg.id);
    });

    test('equality berdasarkan id', () {
      final msg1 = ChatMessage(
        id: 'test_id',
        text: 'hello',
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      );
      final msg2 = ChatMessage(
        id: 'test_id',
        text: 'different text',
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
      );
      expect(msg1, equals(msg2)); // sama karena id sama
    });

    test('dua pesan dengan id berbeda harus tidak equal', () {
      final msg1 = ChatMessage.user('hello');
      // Delay sedikit agar timestamp (dan id) berbeda
      final msg2 = ChatMessage.user('hello');
      // id berbasis millisecond, tapi bisa sama jika terlalu cepat
      // Jadi kita buat manual:
      final a = ChatMessage(
        id: 'a',
        text: 'hello',
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      );
      final b = ChatMessage(
        id: 'b',
        text: 'hello',
        sender: MessageSender.user,
        timestamp: DateTime.now(),
      );
      expect(a, isNot(equals(b)));
    });
  });

  // ──────────────────────────────────────────────────────────────
  // GROUP 2: Health Topic Detection
  // ──────────────────────────────────────────────────────────────
  group('ChatbotService - isHealthTopic()', () {
    test('topik penyakit harus terdeteksi sebagai health topic', () {
      expect(ChatbotService.isHealthTopic('saya sakit kepala'), true);
      expect(ChatbotService.isHealthTopic('gejala demam tinggi'), true);
      expect(ChatbotService.isHealthTopic('obat batuk apa yang bagus'), true);
      expect(ChatbotService.isHealthTopic('saya alergi udang'), true);
    });

    test('topik nutrisi/olahraga harus terdeteksi sebagai health topic', () {
      expect(ChatbotService.isHealthTopic('tips diet sehat'), true);
      expect(ChatbotService.isHealthTopic('nutrisi untuk ibu hamil'), true);
      expect(ChatbotService.isHealthTopic('olahraga untuk pemula'), true);
      expect(ChatbotService.isHealthTopic('cara tidur nyenyak'), true);
    });

    test('topik fasilitas kesehatan harus terdeteksi', () {
      expect(ChatbotService.isHealthTopic('rumah sakit di indramayu'), true);
      expect(ChatbotService.isHealthTopic('puskesmas terdekat'), true);
      expect(ChatbotService.isHealthTopic('apotek 24 jam'), true);
      expect(ChatbotService.isHealthTopic('dokter spesialis'), true);
    });

    test('pertanyaan identitas harus terdeteksi', () {
      expect(ChatbotService.isHealthTopic('siapa kamu'), true);
      expect(ChatbotService.isHealthTopic('kamu siapa anda'), true);
    });

    test('topik non-kesehatan harus DITOLAK', () {
      expect(ChatbotService.isHealthTopic('siapa presiden indonesia'), false);
      expect(ChatbotService.isHealthTopic('bagaimana cara coding'), false);
      expect(ChatbotService.isHealthTopic('rekomendasi film'), false);
      expect(ChatbotService.isHealthTopic('harga bitcoin hari ini'), false);
      expect(ChatbotService.isHealthTopic('tips main game'), false);
    });

    test('string kosong harus DITOLAK', () {
      expect(ChatbotService.isHealthTopic(''), false);
      expect(ChatbotService.isHealthTopic('   '), false);
    });

    test('case insensitive harus bekerja', () {
      expect(ChatbotService.isHealthTopic('SAKIT KEPALA'), true);
      expect(ChatbotService.isHealthTopic('Demam Tinggi'), true);
      expect(ChatbotService.isHealthTopic('RUMAH SAKIT'), true);
    });
  });

  // ──────────────────────────────────────────────────────────────
  // GROUP 3: Offline Response (tanpa API key)
  // ──────────────────────────────────────────────────────────────
  group('ChatbotService - Offline Response', () {
    late ChatbotService service;

    setUp(() {
      service = ChatbotService();
    });

    test('pertanyaan identitas harus dijawab dengan info ELSA', () async {
      final response = await service.sendMessage('siapa kamu');
      expect(response.toLowerCase(), contains('elsa'));
      expect(response.toLowerCase(), contains('bayu'));
    });

    test('pertanyaan non-kesehatan harus ditolak sopan', () async {
      final response = await service.sendMessage('siapa presiden');
      expect(response.toLowerCase(), contains('kesehatan'));
      expect(response.toLowerCase(), contains('maaf'));
    });

    test('pertanyaan fasilitas kesehatan harus dijawab', () async {
      final response = await service.sendMessage('rumah sakit di indramayu');
      expect(response.toLowerCase(), contains('rsud'));
    });

    test('pertanyaan kesehatan umum harus dijawab', () async {
      final response = await service.sendMessage('saya sakit kepala');
      expect(response, isNotEmpty);
      // Harus mengandung disclaimer
      expect(response, contains('⚠️'));
    });
  });

  // ──────────────────────────────────────────────────────────────
  // GROUP 4: Conversation Management
  // ──────────────────────────────────────────────────────────────
  group('ChatbotService - Conversation Management', () {
    late ChatbotService service;

    setUp(() {
      service = ChatbotService();
    });

    test('clearHistory harus berhasil tanpa error', () {
      // Seharusnya tidak throw exception
      expect(() => service.clearHistory(), returnsNormally);
    });

    test('multiple messages harus bisa dikirim berurutan', () async {
      final r1 = await service.sendMessage('siapa kamu');
      final r2 = await service.sendMessage('sakit kepala');
      expect(r1, isNotEmpty);
      expect(r2, isNotEmpty);
    });
  });

  // ──────────────────────────────────────────────────────────────
  // GROUP 5: Static Properties
  // ──────────────────────────────────────────────────────────────
  group('ChatbotService - Static Properties', () {
    test('welcomeMessage harus tidak kosong', () {
      expect(ChatbotService.welcomeMessage, isNotEmpty);
      expect(ChatbotService.welcomeMessage.toLowerCase(), contains('elsa'));
    });

    test('quickSuggestions harus memiliki minimal 3 item', () {
      expect(ChatbotService.quickSuggestions.length, greaterThanOrEqualTo(3));
    });

    test('semua quickSuggestions harus tidak kosong', () {
      for (final s in ChatbotService.quickSuggestions) {
        expect(s, isNotEmpty);
      }
    });
  });
}
