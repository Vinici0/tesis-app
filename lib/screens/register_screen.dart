import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_adv/blocs/auth/auth_bloc.dart';
import 'package:flutter_maps_adv/helpers/mostrar_alerta.dart';
import 'package:flutter_maps_adv/screens/screens.dart';
import 'package:flutter_maps_adv/widgets/boton_login.dart';
import 'package:flutter_maps_adv/widgets/custom_input.dart';
import 'package:flutter_maps_adv/widgets/labels_login.dart';
import 'package:flutter_maps_adv/widgets/logo_login.dart';

class RegisterScreen extends StatelessWidget {
  static const String registerroute = 'register';

  const RegisterScreen({Key? key}) : super(key: key);

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
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Logo(text: "REGISTRO"),
                    _From(),
                    Labels(
                        ruta: 'login',
                        text: "¿Ya tienes cuenta?",
                        text2: "Ingresa"),
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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nomController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final authServiceBloc = BlocProvider.of<AuthBloc>(context);

    return Column(children: [
      //Nombre
      CustonInput(
        icon: Icons.perm_identity,
        placeholder: "Nombre",
        keyboardType: TextInputType.text,
        textController: nomController,
      ),

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
        text: "Crear cuenta",
        onPressed: authServiceBloc.isLoggedInTrue
            ? () {}
            : () async {
                FocusScope.of(context).unfocus();

                await authServiceBloc.register(
                    nomController.text.trim(),
                    emailController.text.trim(),
                    passwordController.text.trim());

                if (authServiceBloc.isLoggedInTrue) {
                  // ignore: use_build_context_synchronously
                  Navigator.pushReplacementNamed(
                      context, LoadingLoginScreen.loadingroute);
                } else {
                  //mostrar alerta
                  // ignore: use_build_context_synchronously
                  mostrarAlerta(context, 'Login incorrecto',
                      'Revise sus credenciales nuevamente');
                }
              },
      )
    ]);
  }
}
