import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/widgets/alwan_page_header.dart';
import 'package:alwan_hub/features/more/presentation/widgets/more_typography.dart';
import 'package:alwan_hub/features/notifications/presentation/pages/notifications_screen.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoreTypography(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FD),
        body: Column(
          children: [
            AlwanPageHeader(
              title: 'تواصل معنا',
              subtitle: 'نحن هنا للاستماع إليك، تواصل معنا الآن',
              onNotificationTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 30),
                child: ResponsiveContent(
                  maxWidth: 820,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ContactMethods(),
                      SizedBox(height: 18),
                      ContactMessageForm(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactMethods extends StatelessWidget {
  const _ContactMethods();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ContactMethodCard(
            icon: Icons.public_rounded,
            title: 'مواقع التواصل',
            value: 'تابعنا على المنصات',
            color: const Color(0xFF8B2CA8),
            onTap: () => launchUrl(
              Uri.parse('https://alwan.fm'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: ContactMethodCard(
            icon: Icons.email_outlined,
            title: 'البريد الإلكتروني',
            value: 'contact@alwanfm.sa',
            color: const Color(0xFF298FCE),
            onTap: () => launchUrl(
              Uri.parse('mailto:contact@alwanfm.sa'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: ContactMethodCard(
            icon: Icons.chat_rounded,
            title: 'واتساب',
            value: '+966 55 123 4567',
            color: const Color(0xFF40A95A),
            onTap: () => launchUrl(
              Uri.parse('https://wa.me/966551234567'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: ContactMethodCard(
            icon: Icons.call_rounded,
            title: 'اتصل بنا',
            value: '+966 11 234 5678',
            color: const Color(0xFF5A4A9C),
            onTap: () => launchUrl(
              Uri.parse('tel:+966112345678'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ),
      ],
    );
  }
}

class ContactMethodCard extends StatelessWidget {
  const ContactMethodCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          constraints: const BoxConstraints(minHeight: 126),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFE0E4EB)),
          ),
          child: Column(
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .11),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 7),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF302F6A),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontFamily: 'MohammadBoldArt',
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactMessageForm extends StatefulWidget {
  const ContactMessageForm({super.key, this.title = 'أرسل لنا رسالة'});

  final String title;

  @override
  State<ContactMessageForm> createState() => _ContactMessageFormState();
}

class _ContactMessageFormState extends State<ContactMessageForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFD9E0EA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11131B2D),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF343A8D), Color(0xFF9E25AE)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mail_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Color(0xFF292F70),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.translateInterface('الاسم'),
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              validator: (value) => value == null || value.trim().length < 2
                  ? context.translateInterface('أدخل اسمك من فضلك')
                  : null,
            ),
            const SizedBox(height: 11),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.translateInterface('البريد الإلكتروني'),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) {
                  return context.translateInterface('أدخل بريدك الإلكتروني');
                }
                if (!email.contains('@')) {
                  return context.translateInterface(
                    'البريد الإلكتروني غير صحيح',
                  );
                }
                return null;
              },
            ),
            const SizedBox(height: 11),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.translateInterface('رقم الجوال'),
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 11),
            TextFormField(
              controller: _messageController,
              minLines: 4,
              maxLines: 7,
              maxLength: 800,
              decoration: InputDecoration(
                labelText: context.translateInterface('اكتب رسالتك هنا'),
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 76),
                  child: Icon(Icons.chat_bubble_outline_rounded),
                ),
              ),
              validator: (value) => value == null || value.trim().length < 8
                  ? context.translateInterface('اكتب رسالة أوضح من فضلك')
                  : null,
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF343A8D), Color(0xFF9E25AE)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ElevatedButton.icon(
                  onPressed: _sending ? null : _send,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 20),
                  label: Text(
                    _sending ? 'جارٍ التجهيز...' : 'إرسال الرسالة',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);

    final body = [
      'الاسم: ${_nameController.text.trim()}',
      'البريد: ${_emailController.text.trim()}',
      'الجوال: ${_phoneController.text.trim()}',
      '',
      _messageController.text.trim(),
    ].join('\n');
    final uri = Uri(
      scheme: 'mailto',
      path: 'contact@alwanfm.sa',
      queryParameters: {
        'subject': 'رسالة جديدة من تطبيق منصة ألوان',
        'body': body,
      },
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    setState(() => _sending = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          opened
              ? 'تم تجهيز الرسالة في تطبيق البريد'
              : 'تعذر فتح البريد، يمكنك مراسلتنا على contact@alwanfm.sa',
        ),
      ),
    );
  }
}
