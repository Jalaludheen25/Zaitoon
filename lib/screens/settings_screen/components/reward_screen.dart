import 'package:flutter/material.dart';

class RewardScreen extends StatelessWidget {
  final int storiesCompleted;
  final int totalReadingMinutes;
  final int currentStreak;
  final int longestStreak;
  final double completionRate;

  const RewardScreen({
    super.key,
    required this.storiesCompleted,
    required this.totalReadingMinutes,
    required this.currentStreak,
    required this.longestStreak,
    required this.completionRate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'My Reading Journey 🚀',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 30),
              _buildStatsGrid(),
              const SizedBox(height: 30),
              _buildAchievementsSection(),
              const SizedBox(height: 30),
              _buildProgressBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.deepPurpleAccent.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          const Text(
            '🎉 Amazing Progress! 🎉',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You\'ve completed $storiesCompleted stories',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard('📚 Stories', storiesCompleted.toString(), Colors.blue),
        _buildStatCard(
            '⏱️ Minutes', totalReadingMinutes.toString(), Colors.green),
        _buildStatCard(
            '🔥 Current Streak', currentStreak.toString(), Colors.orange),
        _buildStatCard(
            '⭐ Best Streak', longestStreak.toString(), Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🏆 Achievements',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        _buildAchievementCard(
          emoji: '🌟',
          title: 'Story Master',
          description: 'Completed $storiesCompleted stories',
          color: Colors.amber,
        ),
        const SizedBox(height: 10),
        _buildAchievementCard(
          emoji: '⚡',
          title: 'Speed Reader',
          description: '$totalReadingMinutes minutes of reading',
          color: Colors.blue,
        ),
        const SizedBox(height: 10),
        _buildAchievementCard(
          emoji: '🎯',
          title: 'Focused Reader',
          description: '$currentStreak days streak',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildAchievementCard({
    required String emoji,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 Completion Rate',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 25,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.5),
            child: LinearProgressIndicator(
              value: completionRate / 100,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.deepPurpleAccent,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${completionRate.toStringAsFixed(1)}% Complete',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}
