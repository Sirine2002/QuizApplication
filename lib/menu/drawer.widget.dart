import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDrawer extends StatelessWidget {
  final String? username;
  final String? email;

  const CustomDrawer({Key? key, this.username, this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber, Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(''),
            accountEmail: Text(
              username ?? 'No Guest',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.amber),
            ),
          ),

          ListTile(
            leading: Icon(Icons.home, color: Colors.black),
            title: Text('Home',style: GoogleFonts.poppins(
    fontWeight: FontWeight.bold,
    fontSize: 14,),),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.person, color: Colors.black),
            title: Text('Profile',style: GoogleFonts.poppins(
    fontWeight: FontWeight.bold,
    fontSize: 14,),),
            onTap: () {
              Navigator.pop(context); // Ferme le Drawer
              Navigator.pushNamed(context, '/profile'); // Navigue vers Settings
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.black),
            title: Text('Settings',style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                            fontSize: 14,),),
            onTap: () {
              Navigator.pop(context); // Ferme le Drawer
              Navigator.pushNamed(context, '/settings'); // Navigue vers Settings
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.black),
            title: Text('Logout',style: GoogleFonts.poppins(
    fontWeight: FontWeight.bold,
    fontSize: 14,),),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, "/Quiz", (route) => false); // Naviguer vers la page d'inscription
            },
          ),
        ],
      ),
    );
  }
}

