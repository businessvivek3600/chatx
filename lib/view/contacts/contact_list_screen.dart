import 'package:chatx/core/widgets/user_list_tile.dart';
import 'package:chatx/providers/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactsPage extends ConsumerStatefulWidget {
  const ContactsPage({super.key});

  @override
  ConsumerState<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends ConsumerState<ContactsPage> {
  Future<void> onRefresh() async {
    /// clear friendship cache before refreshing
    ref.invalidate(contactProvider);
    ref.invalidate(requestProvider);

    /// wait a bit for the provider refresh to complete
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(autoRefreshProvider);
    final contact = ref.watch(filteredUsersProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'All Contacts',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              onChanged: (value) =>
                  ref.read(searchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'enter here name or email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () =>
                            ref.read(searchQueryProvider.notifier).state = '',
                      )
                    : null,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: RefreshIndicator(
          backgroundColor: Colors.white,
          onRefresh: onRefresh,
          child: contact.when(
            data: (contactList) {
              /// 🔹 EMPTY SEARCH RESULT
              if (contactList.isEmpty && searchQuery.isEmpty) {
                return ListView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  children: const [
                    SizedBox(height: 20),
                    Center(child: Text('No users found matching your search')),
                  ],
                );
              }

              /// 🔹 NO CONTACTS
              if (contactList.isEmpty) {
                return ListView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  children: const [
                    SizedBox(height: 200),
                    Center(child: Text('No other user found')),
                  ],
                );
              }

              /// 🔹 CONTACT LIST
              return ListView.builder(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                itemCount: contactList.length,
                itemBuilder: (context, index) {
                  final user = contactList[index];
                  return UserListTile(user: user);
                },
              );
            },

            error: (_, __) => ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
            ),

            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}
