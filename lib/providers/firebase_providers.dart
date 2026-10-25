import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

/// Provider for FirebaseAuth instance
class FirebaseAuthProvider extends InheritedWidget {
  final FirebaseAuth firebaseAuth;

  const FirebaseAuthProvider({
    super.key,
    required this.firebaseAuth,
    required super.child,
  });

  static FirebaseAuth of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<FirebaseAuthProvider>();
    assert(provider != null, 'No FirebaseAuthProvider found in context');
    return provider!.firebaseAuth;
  }

  @override
  bool updateShouldNotify(FirebaseAuthProvider oldWidget) =>
      firebaseAuth != oldWidget.firebaseAuth;
}

/// Provider for FirebaseFirestore instance
class FirebaseFirestoreProvider extends InheritedWidget {
  final FirebaseFirestore firestore;

  const FirebaseFirestoreProvider({
    super.key,
    required this.firestore,
    required super.child,
  });

  static FirebaseFirestore of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<FirebaseFirestoreProvider>();
    assert(provider != null, 'No FirebaseFirestoreProvider found in context');
    return provider!.firestore;
  }

  @override
  bool updateShouldNotify(FirebaseFirestoreProvider oldWidget) =>
      firestore != oldWidget.firestore;
}

/// Provider for FirebaseStorage instance
class FirebaseStorageProvider extends InheritedWidget {
  final FirebaseStorage storage;

  const FirebaseStorageProvider({
    super.key,
    required this.storage,
    required super.child,
  });

  static FirebaseStorage of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<FirebaseStorageProvider>();
    assert(provider != null, 'No FirebaseStorageProvider found in context');
    return provider!.storage;
  }

  @override
  bool updateShouldNotify(FirebaseStorageProvider oldWidget) =>
      storage != oldWidget.storage;
}

/// Convenience wrapper that provides all Firebase instances
class FirebaseProviders extends StatelessWidget {
  final FirebaseAuth? firebaseAuth;
  final FirebaseFirestore? firestore;
  final FirebaseStorage? storage;
  final Widget child;

  const FirebaseProviders({
    super.key,
    this.firebaseAuth,
    this.firestore,
    this.storage,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FirebaseAuthProvider(
      firebaseAuth: firebaseAuth ?? FirebaseAuth.instance,
      child: FirebaseFirestoreProvider(
        firestore: firestore ?? FirebaseFirestore.instance,
        child: FirebaseStorageProvider(
          storage: storage ?? FirebaseStorage.instance,
          child: child,
        ),
      ),
    );
  }
}
