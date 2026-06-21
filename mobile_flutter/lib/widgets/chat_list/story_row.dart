import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/chat_item.dart';

const _primary      = Color(0xFF2563EB);
const _accentPurple = Color(0xFF7C3AED);
const _textDark     = Color(0xFF0F172A);
const _textMuted    = Color(0xFF94A3B8);
const _divider      = Color(0xFFE2E8F0);

const _storyGradient = LinearGradient(
  colors: [_primary, _accentPurple],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ── Story row ─────────────────────────────────────────────────────────────────

class ChatStoryRow extends StatelessWidget {
  const ChatStoryRow({super.key, this.stories = const [], this.myInitials = 'ME'});

  final List<StoryItem> stories;
  final String myInitials;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 106,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: stories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final s = stories[i];
          if (s.isSelf) {
            return _SelfStory(initials: myInitials, colorIndex: s.colorIndex);
          }
          return _StoryBubble(story: s);
        },
      ),
    );
  }
}

// ── Self story (with + badge) ─────────────────────────────────────────────────

class _SelfStory extends StatelessWidget {
  const _SelfStory({required this.initials, required this.colorIndex});

  final String initials;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final bgColor = Color(kAvatarColors[colorIndex % kAvatarColors.length]);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bgColor.withValues(alpha: 0.15),
                  border: Border.all(color: _divider, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: bgColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.add, size: 13, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 64,
          child: Text(
            'Your Story',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _textMuted,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Other story bubble ────────────────────────────────────────────────────────

class _StoryBubble extends StatelessWidget {
  const _StoryBubble({required this.story});

  final StoryItem story;

  @override
  Widget build(BuildContext context) {
    final bgColor = Color(kAvatarColors[story.colorIndex % kAvatarColors.length]);

    Widget avatar = Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      child: story.avatarUrl != null
          ? ClipOval(
              child: Image.network(
                story.avatarUrl!,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (_, __, ___) => _AvatarInitials(story.initials),
              ),
            )
          : _AvatarInitials(story.initials),
    );

    if (story.hasUnviewed) {
      avatar = Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: _storyGradient,
        ),
        padding: const EdgeInsets.all(2.5),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(1.5),
          child: avatar,
        ),
      );
    } else {
      avatar = Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _divider, width: 1.5),
        ),
        padding: const EdgeInsets.all(2),
        child: avatar,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        avatar,
        const SizedBox(height: 5),
        SizedBox(
          width: 64,
          child: Text(
            story.name.split(' ').first,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _textDark,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _AvatarInitials extends StatelessWidget {
  const _AvatarInitials(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      text,
      style: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
  );
}
