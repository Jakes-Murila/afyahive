import 'package:flutter/material.dart';

import 'resource_list_screen.dart';

class ServiceCatalog {
  static void open(BuildContext context, String name) {
    final page = switch (name) {
      'Book an appointment' => const ResourceListScreen(
        title: 'Appointments',
        route: 'appointments',
        emptyMessage: 'No appointments yet.',
        icon: Icons.calendar_month_outlined,
        fields: [
          ResourceField('provider_name', 'Provider name', required: true),
          ResourceField('specialty', 'Specialty'),
          ResourceField(
            'scheduled_at',
            'Scheduled at (YYYY-MM-DD HH:MM:SS)',
            required: true,
          ),
          ResourceField('location', 'Location'),
          ResourceField(
            'mode',
            'Visit type',
            kind: InputKind.select,
            options: ['in_person', 'telemedicine'],
          ),
          ResourceField('notes', 'Notes', kind: InputKind.multiline),
        ],
      ),
      'Medicine reminders' => const ResourceListScreen(
        title: 'Medicine reminders',
        route: 'reminders',
        emptyMessage: 'No medicine reminders yet.',
        icon: Icons.medication_outlined,
        fields: [
          ResourceField('medication_name', 'Medicine name', required: true),
          ResourceField('dosage', 'Dosage'),
          ResourceField('schedule_time', 'Time (HH:MM:SS)', required: true),
          ResourceField(
            'frequency',
            'Frequency',
            kind: InputKind.select,
            options: ['daily', 'weekly', 'as_needed'],
          ),
          ResourceField('is_active', 'Reminder active', kind: InputKind.toggle),
          ResourceField('notes', 'Notes', kind: InputKind.multiline),
        ],
      ),
      'Telemedicine' => const ResourceListScreen(
        title: 'Telemedicine',
        route: 'telemedicine',
        emptyMessage: 'No telemedicine sessions yet.',
        icon: Icons.video_camera_front_outlined,
        fields: [
          ResourceField('provider_name', 'Provider name', required: true),
          ResourceField(
            'scheduled_at',
            'Scheduled at (YYYY-MM-DD HH:MM:SS)',
            required: true,
          ),
          ResourceField('meeting_url', 'Meeting URL'),
          ResourceField(
            'status',
            'Status',
            kind: InputKind.select,
            options: ['scheduled', 'completed', 'cancelled'],
          ),
        ],
      ),
      'Medical records' => const ResourceListScreen(
        title: 'Medical records',
        route: 'medical-records',
        emptyMessage: 'No medical records yet.',
        icon: Icons.folder_shared_outlined,
        fields: [
          ResourceField(
            'record_type',
            'Record type',
            required: true,
            kind: InputKind.select,
            options: ['lab_result', 'prescription', 'diagnosis', 'document'],
          ),
          ResourceField('title', 'Title', required: true),
          ResourceField('details', 'Details', kind: InputKind.multiline),
          ResourceField('issued_at', 'Issued date (YYYY-MM-DD)'),
          ResourceField('file_url', 'Secure file URL'),
        ],
      ),
      'Health community' => const ResourceListScreen(
        title: 'Health community',
        route: 'community-posts',
        emptyMessage: 'No community posts yet.',
        icon: Icons.groups_2_outlined,
        fields: [
          ResourceField(
            'body',
            'Share an update',
            required: true,
            kind: InputKind.multiline,
          ),
          ResourceField(
            'is_anonymous',
            'Post anonymously',
            kind: InputKind.toggle,
          ),
        ],
      ),
      'Emergency contacts' => const ResourceListScreen(
        title: 'Emergency contacts',
        route: 'emergency-contacts',
        emptyMessage: 'Add a trusted contact for emergencies.',
        icon: Icons.emergency_outlined,
        fields: [
          ResourceField('name', 'Full name', required: true),
          ResourceField('relationship', 'Relationship', required: true),
          ResourceField('phone', 'Phone number', required: true),
          ResourceField(
            'is_primary',
            'Primary contact',
            kind: InputKind.toggle,
          ),
        ],
      ),
      'Fitness integration' => const ResourceListScreen(
        title: 'Activity tracking',
        route: 'activities',
        emptyMessage: 'No activity has been logged yet.',
        icon: Icons.directions_walk_rounded,
        fields: [
          ResourceField(
            'activity_type',
            'Activity type',
            required: true,
            kind: InputKind.select,
            options: [
              'Walking',
              'Running',
              'Cycling',
              'Swimming',
              'Yoga',
              'Other',
            ],
          ),
          ResourceField(
            'duration_minutes',
            'Duration in minutes',
            required: true,
            kind: InputKind.number,
          ),
          ResourceField(
            'calories_burned',
            'Calories burned',
            required: true,
            kind: InputKind.number,
          ),
          ResourceField('distance_km', 'Distance (km)', kind: InputKind.number),
          ResourceField(
            'activity_date',
            'Activity date (YYYY-MM-DD)',
            required: true,
          ),
          ResourceField('notes', 'Notes', kind: InputKind.multiline),
        ],
      ),
      _ => null,
    };
    if (page == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This clinical service requires an approved provider integration before it can be used.',
          ),
        ),
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}
