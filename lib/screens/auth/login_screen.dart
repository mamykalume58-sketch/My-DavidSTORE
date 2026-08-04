import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    try {
      await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _googleLogin() async {
    setState(() {
      _loading = true;
    });

    try {
      final user = await _authService.signInWithGoogle();

      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [

                const SizedBox(height:40),

                const Text(
                  "Connexion",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:28,
                    fontWeight:FontWeight.bold,
                    color:Color(0xFF0A1030),
                  ),
                ),

                const SizedBox(height:32),

                TextFormField(
                  controller:_emailController,
                  keyboardType:TextInputType.emailAddress,

                  decoration:const InputDecoration(
                    labelText:"Adresse e-mail",
                    border:OutlineInputBorder(),
                  ),

                  validator:(value){
                    if(value==null || value.isEmpty){
                      return "Veuillez entrer votre e-mail";
                    }

                    return null;
                  },
                ),

                const SizedBox(height:16),

                TextFormField(
                  controller:_passwordController,
                  obscureText:_obscurePassword,

                  decoration:InputDecoration(
                    labelText:"Mot de passe",
                    border:const OutlineInputBorder(),

                    suffixIcon:IconButton(
                      icon:Icon(
                        _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                      ),

                      onPressed:(){
                        setState(() {
                          _obscurePassword=!_obscurePassword;
                        });
                      },
                    ),
                  ),

                  validator:(value){
                    if(value==null || value.isEmpty){
                      return "Veuillez entrer votre mot de passe";
                    }

                    return null;
                  },
                ),

                Align(
                  alignment:Alignment.centerRight,

                  child:TextButton(
                    onPressed:(){},

                    child:const Text(
                      "Mot de passe oublié ?",
                    ),
                  ),
                ),

                const SizedBox(height:16),

                ElevatedButton(

                  style:ElevatedButton.styleFrom(
                    backgroundColor:const Color(0xFFFF6B35),

                    padding:const EdgeInsets.symmetric(
                      vertical:16,
                    ),
                  ),

                  onPressed:_loading ? null : _login,

                  child:_loading
                  ? const CircularProgressIndicator(
                      color:Colors.white,
                    )

                  : const Text(
                      "Se connecter",
                      style:TextStyle(
                        color:Colors.white,
                        fontSize:16,
                      ),
                    ),
                ),


                const SizedBox(height:24),


                const Row(
                  children:[
                    Expanded(child:Divider()),

                    Padding(
                      padding:EdgeInsets.symmetric(horizontal:8),

                      child:Text(
                        "OU CONTINUER AVEC",
                      ),
                    ),

                    Expanded(child:Divider()),
                  ],
                ),


                const SizedBox(height:16),


                OutlinedButton.icon(

                  onPressed:_loading ? null : _googleLogin,

                  icon:const Icon(
                    Icons.g_mobiledata,
                    size:28,
                  ),

                  label:const Text(
                    "Continuer avec Google",
                  ),
                ),


                const SizedBox(height:24),


                Row(
                  mainAxisAlignment:MainAxisAlignment.center,

                  children:[

                    const Text(
                      "Pas encore de compte ? ",
                    ),

                    GestureDetector(

                      onTap:(){
                        Navigator.pushNamed(
                          context,
                          '/register',
                        );
                      },

                      child:const Text(
                        "S'inscrire",

                        style:TextStyle(
                          color:Color(0xFFFF6B35),
                          fontWeight:FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
