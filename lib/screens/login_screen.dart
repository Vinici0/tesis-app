import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_adv/blocs/auth/auth_bloc.dart';
import 'package:flutter_maps_adv/helpers/mostrar_alerta.dart';
import 'package:flutter_maps_adv/screens/screens.dart';
import 'package:flutter_maps_adv/widgets/boton_login.dart';
import 'package:flutter_maps_adv/widgets/custom_input.dart';
import 'package:flutter_maps_adv/widgets/labels_login.dart';
import 'package:flutter_maps_adv/widgets/logo_login.dart';

class LoginScreen extends StatelessWidget {
  static const String loginroute = 'login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              margin: const EdgeInsets.all(30),
              height: MediaQuery.of(context).size.height * 0.99,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Logo(text: "Seguridad ESPE"),
                    _From(),
                    Labels(
                        ruta: 'register',
                        text: "¿No tienes cuenta?",
                        text2: "Crea una"),
                    SizedBox(height: 10),
                    Text("Terminos y condiciones de uso",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(0, 0, 0, 0.782)))
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _From extends StatefulWidget {
  const _From({super.key});

  @override
  State<_From> createState() => __FromState();
}

class __FromState extends State<_From> {
  //provider

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return Column(children: [
      CustonInput(
        icon: Icons.mail_outline,
        placeholder: "Email",
        keyboardType: TextInputType.emailAddress,
        textController: emailController,
      ),
      CustonInput(
        icon: Icons.lock_outline,
        placeholder: "Password",
        textController: passwordController,
        isPassword: true,
      ),
      BotonForm(
        text: "Ingrese",
        onPressed: () async {
          FocusScope.of(context).unfocus();
          await authBloc.login(emailController.text, passwordController.text);
          if (authBloc.isLoggedInTrue) {
            // ignore: use_build_context_synchronously
            Navigator.pushReplacementNamed(
                context, LoadingLoginScreen.loadingroute);
          } else {
            // ignore: use_build_context_synchronously
            mostrarAlerta(context, "Login incorrecto",
                "Revise sus credenciales nuevamente");
          }
        },
      ),
      //----or----
      const SizedBox(height: 10),
      const Text("O continue con"),
      const SizedBox(height: 10),
      BotonForm(
        text: "Google",
        onPressed: () async {
          try {
            FocusScope.of(context).unfocus();
            await authBloc.signInWithGoogle();
            if (authBloc.isLoggedInTrue) {
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(
                  context, LoadingLoginScreen.loadingroute);
            }
          } catch (e) {
            print(e);
          }
        },
      ),
      //cerrar sesion
    ]);
  }
}
