import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

/// Consolidated view for student profile, language level, and assessment data
class StudentProfileView extends StatelessWidget {
  const StudentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfilePictureCard(),
            SizedBox(height: 16),
            LanguageLevelCard(),
            SizedBox(height: 16),
            ProfileDataCard(),
          ],
        ),
      ),
    );
  }
}
