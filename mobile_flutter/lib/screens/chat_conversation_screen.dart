import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/message.dart';
import '../widgets/chat/message_bubble.dart';
import '../widgets/chat/date_divider.dart';
import '../widgets/chat/loading_skeleton.dart';
import '../widgets/chat/input_bar.dart';
import '../widgets/chat/coming_soon_sheet.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────

const _bg            = Color(0xFF0A0A0F);
const _accentBlue    = Color(0xFF00D4FF);
const _accentPurple  = Color(0xFF7C3AED);
const _textPrimary   = Colors.white;
const _textMuted     = Color(0xFF5A5A6E);
const _online        = Color(0xFF00E676);
const _verifiedGold  = Color(0xFFFFD700);

TextStyle _sg(double size, FontWeight w, Color c, {double? ls, double? h}) =>
    GoogleFonts.spaceGrotesk(fontSize: size, fontWeight: w, color: c, letterSpacing: ls, height: h);

// ── Chat Conversation Screen ──────────────────────────────────────────────────

class ChatConversationScreen extends StatefulWidget {
  const ChatConversationScreen({
    super.key,
    required this.conversationId,
    this.contactName = 'Yaa Debby',
    this.isOnline = true,
    this.isVerified = true,
  });

  final String conversationId;
  final String contactName;
  final bool isOnline;
  final bool isVerified;

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _input = TextEditingController();

  bool _appBarSolid = false;
  bool _isLoading   = true;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);

    // Simulate message loading
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _input.dispose();
    super.dispose();
  }

  void _onScroll() {
    // reverse: true means offset > 0 means user scrolled up (toward older messages)
    final solid = _scroll.offset > 20;
    if (solid != _appBarSolid) {
      setState(() => _appBarSolid = solid);
    }
  }

  void _onSend() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    // In a real app: dispatch send message action
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // ── Message list ─────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const ChatLoadingSkeleton()
                : _MessageList(
                    entries: const [],
                    scrollController: _scroll,
                  ),
          ),
          // ── Input bar ────────────────────────────────────────────────────
          ChatInputBar(
            controller: _input,
            onGamingTap: () => showGamingComingSoonSheet(context),
            onSend: _onSend,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        color: _appBarSolid ? _bg : Colors.transparent,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _textPrimary, size: 20),
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: 'Back',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  const SizedBox(width: 4),
                  // Contact avatar with online dot
                  _HeaderAvatar(
                    name: widget.contactName,
                    isOnline: widget.isOnline,
                  ),
                  const SizedBox(width: 10),
                  // Name + status column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.contactName,
                              style: _sg(17, FontWeight.w600, _textPrimary),
                            ),
                            if (widget.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.star_rounded, size: 14, color: _verifiedGold),
                            ],
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          widget.isOnline ? 'online' : 'last seen recently',
                          style: _sg(12, FontWeight.w400, widget.isOnline ? _online : _textMuted),
                        ),
                      ],
                    ),
                  ),
                  // Phone call
                  IconButton(
                    icon: const Icon(Icons.phone_rounded, color: _textPrimary, size: 22),
                    onPressed: () {},
                    tooltip: 'Voice call',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(minWidth: 40),
                  ),
                  // Video call
                  IconButton(
                    icon: const Icon(Icons.videocam_rounded, color: _textPrimary, size: 24),
                    onPressed: () {},
                    tooltip: 'Video call',
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(minWidth: 40),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header avatar ─────────────────────────────────────────────────────────────

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({required this.name, required this.isOnline});

  final String name;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_accentPurple, _accentBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (isOnline)
            Positioned(
              bottom: 1,
              right: 1,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: _online,
                  shape: BoxShape.circle,
                  border: Border.all(color: _bg, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Message list ──────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.entries,
    required this.scrollController,
  });

  final List<ChatEntry> entries;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top + 72;

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.only(top: topPad, bottom: 8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];

        if (entry is ChatDateDivider) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ChatDateDividerRow(label: entry.label),
          );
        }

        if (entry is ChatMessage) {
          final msg = entry.message;
          // Determine group context (adjacent items with reverse: true)
          // index - 1 is visually BELOW (newer), index + 1 is visually ABOVE (older)
          final nextEntry = index > 0 ? entries[index - 1] : null;
          final prevEntry = index < entries.length - 1 ? entries[index + 1] : null;

          final nextMsg = nextEntry is ChatMessage ? nextEntry.message : null;
          final prevMsg = prevEntry is ChatMessage ? prevEntry.message : null;

          // First in group = the message that appears TOPMOST in its sender group
          // (no previous message from same sender above it)
          final isFirstInGroup =
              prevMsg == null || prevMsg.isMe != msg.isMe;

          // Last in group = the message that appears BOTTOMMOST
          final isLastInGroup =
              nextMsg == null || nextMsg.isMe != msg.isMe;

          return MessageBubble(
            message: msg,
            isFirstInGroup: isFirstInGroup,
            isLastInGroup: isLastInGroup,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
