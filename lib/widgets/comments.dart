import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_adv/blocs/blocs.dart';
import 'package:flutter_maps_adv/models/publication.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LikesCommentsDetails extends StatefulWidget {
  //comentario, usuario, uid, fecha,
  final Publicacion publicacion;
  final List<String> likes;

  const LikesCommentsDetails({
    Key? key,
    required this.publicacion,
    required this.likes,
  }) : super(key: key);

  @override
  State<LikesCommentsDetails> createState() => _LikesCommentsDetailsState();
}

class _LikesCommentsDetailsState extends State<LikesCommentsDetails> {
  AuthBloc authService = AuthBloc();

  bool isLiked = false;

  @override
  void initState() {
    authService = BlocProvider.of<AuthBloc>(context, listen: false);
    final currentUserUid = authService.state.usuario!.uid;

    if (widget.likes.contains(currentUserUid)) {
      isLiked = true;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authBloc = BlocProvider.of<AuthBloc>(context);

    return BlocBuilder<PublicationBloc, PublicationState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Row(
                //nombre de usuario que publico
                children: [
                  Text(
                    widget.publicacion.usuarioNombre != null
                        ? widget.publicacion.usuarioNombre!
                        : authBloc.state.usuario!.nombre,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const Divider(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Row(
                children: [
                  //TODO: Cambiar el icono
                  IconButton(
                    onPressed: () {
                      _handleLike();
                    },
                    icon: isLiked
                        ? const Icon(
                            FontAwesomeIcons.solidHeart,
                            color: Colors.red,
                          )
                        : const Icon(
                            FontAwesomeIcons.heart,
                            color: Colors.black,
                          ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.publicacion.likes!.length.toString(),
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 28),
                  const Icon(
                    FontAwesomeIcons.comment,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  state.comentariosP.length > 0
                      ? Text(
                          state.comentariosP.length.toString(),
                          style: const TextStyle(fontSize: 20),
                        )
                      : const Text(
                          '0',
                          style: TextStyle(fontSize: 20),
                        ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  _handleLike() async {
    final publicationUid = widget.publicacion.uid!;
    final currentUserUid = authService.state.usuario!.uid;

    try {
      BlocProvider.of<PublicationBloc>(context)
          .add(PublicacionesUpdateEvent(publicationUid));
    } catch (e) {
      print('Error: $e');
    }
    setState(() {
      if (isLiked) {
        widget.publicacion.likes!.remove(currentUserUid);
      } else {
        widget.publicacion.likes!.add(currentUserUid);
      }
      isLiked = !isLiked;
    });
  }
}
