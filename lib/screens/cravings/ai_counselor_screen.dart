import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/ai_chat_message.dart';
import '../../providers/patient_provider.dart';
import '../../services/ai_behavioral_service.dart';
import '../../theme/app_colors.dart';
import 'craving_sos_screen.dart';
import '../../distract.dart';

class AICounselorScreen extends StatefulWidget {
  const AICounselorScreen({super.key});

  @override
  State<AICounselorScreen> createState() => _AICounselorScreenState();
}

class _AICounselorScreenState extends State<AICounselorScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<AIChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendInitialGreeting();
    });
  }

  void _sendInitialGreeting() {
    final patient = Provider.of<PatientProvider>(context, listen: false);
    final isTamil = patient.isTamil;
    final name = patient.userName.isNotEmpty
        ? patient.userName
        : (isTamil ? 'நண்பரே' : 'Friend');

    final welcomeText = isTamil
        ? 'வணக்கம் $name! நான் ஆரியா (Aria), உங்கள் 24/7 AI உளவியல் ஆலோசகர். நீங்கள் இப்போது ${patient.days} நாட்கள் புகைபிடிக்காமல் மகத்தான சாதனை படைத்துள்ளீர்கள். எப்போது ஆசை, பதற்றம் அல்லது சலிப்பு ஏற்பட்டாலும் என்னிடம் சொல்லுங்கள். உங்களுக்கு உதவ நான் எப்போதும் தயார்.'
        : 'Hello $name! I’m Aria, your 24/7 AI Cognitive Behavioral cessation counselor. You are standing strong on Day ${patient.days} of lung recovery! Whenever an urge, work stress, or trigger strikes, talk to me here. We will overcome it together.';

    setState(() {
      _messages.add(
        AIChatMessage(
          id: 'welcome_1',
          text: welcomeText,
          isUser: false,
          timestamp: DateTime.now(),
          actionType: 'breathe',
          actionLabel: isTamil ? 'சுவாசப் பயிற்சியை சோதிக்க' : 'Try 4-7-8 Breathing Pacer',
        ),
      );
    });
  }

  Future<void> _handleSubmitted(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _textController.clear();
    HapticFeedback.lightImpact();

    final userMsg = AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
    });
    _scrollToBottom();

    final patient = Provider.of<PatientProvider>(context, listen: false);
    final isTamil = patient.isTamil;

    try {
      final aiResponse = await AIBehavioralService().chatWithAria(
        userMessage: trimmed,
        history: _messages,
        userName: patient.userName,
        smokeFreeDays: patient.days,
        moneySaved: patient.moneySaved,
        cigarettesAvoided: patient.cigarettesAvoided,
        isTamil: isTamil,
      );

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(aiResponse);
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            AIChatMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              text: isTamil
                  ? 'நான் உங்கள் பக்கத்தில் உள்ளேன். ஒரு மெதுவான மூச்சை உள்ளிழுத்து 3 நிமிடம் பொறுத்திருங்கள்; ஆசையின் அலை தானாகவே தணியும்.'
                  : 'I’m right here beside you. Inhale deeply and give yourself 3 minutes—this urge will collapse.',
              isUser: false,
              timestamp: DateTime.now(),
              actionType: 'breathe',
              actionLabel: isTamil ? '4-7-8 சுவாசம்' : 'Start 4-7-8 Breathing',
            ),
          );
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleActionTap(String? actionType) {
    if (actionType == null) return;
    HapticFeedback.mediumImpact();

    if (actionType == 'breathe' || actionType == 'delay' || actionType == 'water') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CravingSosScreen()),
      );
    } else if (actionType == 'distract') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DistractPage()),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patient = Provider.of<PatientProvider>(context);
    final isTamil = patient.isTamil;

    final quickPrompts = isTamil
        ? [
            '🚨 எனக்கு இப்போது தீவிர ஆசை உள்ளது!',
            '☕ காபிக்கு பின் தோன்றும் ஆசையை எப்படி தடுப்பது?',
            '🫁 இன்று என் நுரையீரல் எப்படி குணமாகிறது?',
            '😰 மன அழுத்தமாக உள்ளது, புகைக்கத் தோன்றுகிறது',
            '💰 இதுவரை எவ்வளவு பணம் சேமித்துள்ளேன்?',
          ]
        : [
            '🚨 I have an intense craving right now!',
            '☕ How to resist post-coffee / meal urges?',
            '🫁 How are my lungs healing today?',
            '😰 I am stressed and thinking of smoking',
            '💰 How much money have I saved so far?',
          ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const CircleAvatar(
                    radius: 19,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.auto_awesome, color: AppColors.primaryTeal, size: 20),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: AppColors.mintFresh,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isTamil ? 'ஆரியா • AI ஆலோசகர்' : 'Aria • AI Counselor',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDeepTeal,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.verified_rounded, size: 14, color: AppColors.skyBlue),
                    ],
                  ),
                  Text(
                    isTamil ? '24/7 மருத்துவ உளவியல் உதவி' : '24/7 Clinical CBT Support',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Language Switcher
          TextButton.icon(
            onPressed: () {
              patient.toggleLanguage();
            },
            icon: const Icon(Icons.translate_rounded, size: 16, color: AppColors.primaryTeal),
            label: Text(
              isTamil ? 'English' : 'தமிழ்',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTeal,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Live Recovery Telemetry Ribbon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryDeepTeal.withValues(alpha: 0.05),
              border: Border(bottom: BorderSide(color: AppColors.lightCardBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 15, color: AppColors.primaryTeal),
                    const SizedBox(width: 6),
                    Text(
                      '${patient.days} ${isTamil ? 'நாட்கள் புகை இல்லை' : 'Days Clean'}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDeepTeal,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${patient.moneySaved.toStringAsFixed(0)} ${isTamil ? 'சேமிப்பு' : 'Saved'}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mintFresh,
                  ),
                ),
                Text(
                  '${patient.cigarettesAvoided} ${isTamil ? 'தவிர்த்தவை' : 'Avoided'}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.skyBlue,
                  ),
                ),
              ],
            ),
          ),

          // Message Thread
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message, isTamil);
              },
            ),
          ),

          // Typing Indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightCardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isTamil ? 'ஆரியா சிந்திக்கிறார்...' : 'Aria is thinking...',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Quick Suggested Prompts Carousel
          Container(
            height: 40,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              itemCount: quickPrompts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final prompt = quickPrompts[i];
                return ActionChip(
                  label: Text(prompt),
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  side: BorderSide(color: AppColors.lightCardBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryDeepTeal,
                  ),
                  onPressed: () => _handleSubmitted(prompt),
                );
              },
            ),
          ),

          // Bottom Input Bar
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _textController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _handleSubmitted,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: isTamil
                              ? 'ஆரியாவிடம் ஆசை அல்லது மனஅழுத்தம் பற்றி பேசவும்...'
                              : 'Talk to Aria about cravings, stress, or health...',
                          hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () => _handleSubmitted(_textController.text),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AIChatMessage message, bool isTamil) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white,
                child: Icon(Icons.auto_awesome, color: AppColors.primaryTeal, size: 14),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primaryTeal : Colors.white,
                    gradient: isUser ? AppColors.primaryGradient : null,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    border: isUser ? null : Border.all(color: AppColors.lightCardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isUser ? Colors.white : AppColors.textDark,
                      height: 1.4,
                    ),
                  ),
                ),
                // Suggested Tool Action Button
                if (!isUser && message.actionType != null && message.actionLabel != null) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _handleActionTap(message.actionType),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.mintFresh.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.mintFresh.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            message.actionType == 'breathe'
                                ? Icons.air_rounded
                                : message.actionType == 'delay'
                                    ? Icons.timer_outlined
                                    : message.actionType == 'water'
                                        ? Icons.water_drop_outlined
                                        : Icons.sports_esports_outlined,
                            size: 16,
                            color: AppColors.primaryDeepTeal,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            message.actionLabel!,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDeepTeal,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.primaryDeepTeal),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primaryDeepTeal,
              child: Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}
