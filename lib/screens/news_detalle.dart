import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_adv/blocs/blocs.dart';
import 'package:flutter_maps_adv/global/environment.dart';
import 'package:flutter_maps_adv/helpers/show_loading_message.dart';
import 'package:flutter_maps_adv/models/publication.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter_maps_adv/widgets/comments.dart';
import 'package:flutter_maps_adv/widgets/comment_pulbicacion.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class DetalleScreen extends StatefulWidget {
  static const String detalleroute = 'detalle';
  const DetalleScreen({Key? key}) : super(key: key);

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  PublicationBloc publicationBloc = PublicationBloc();
  bool _estaEscribiendo = false;
  AuthBloc authService = AuthBloc();

  final _textController = TextEditingController();

  @override
  void initState() {
    publicationBloc = BlocProvider.of<PublicationBloc>(context);
    publicationBloc.add(CountCommentEvent(publicationBloc.state.publicaciones
        .where((element) =>
            element.uid == publicationBloc.state.currentPublicacion!.uid)
        .first
        .comentarios!
        .length));
    _caragrHistorial(publicationBloc.state.currentPublicacion!.uid!);
    authService = BlocProvider.of<AuthBloc>(context, listen: false);

    authService.socketService.socket.emit('join-room', {
      'codigo': publicationBloc.state.currentPublicacion!.uid!,
    });

    authService.socketService.socket
        .on('comentario-publicacion', _escucharComeentario);

    super.initState();
  }

  void _caragrHistorial(String uid) async {
    await publicationBloc
        .getAllComments(publicationBloc.state.currentPublicacion!.uid!);
  }

  void _escucharComeentario(dynamic payload) {
    CommentPublication comment = CommentPublication(
      comentario: payload['mensaje'],
      nombre: payload['nombre'],
      fotoPerfil: payload['fotoPerfil'],
      createdAt: payload['createdAt'],
      uid: payload['uid'],
      likes: payload['likes'],
    );

    publicationBloc.add(AddCommentPublicationEvent(comment));

    setState(() {
      // publicationBloc.comentariosP.insert(0, comment);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> mapNews =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final publicacion = mapNews['publicacion'] as Publicacion;
    final List<String>? likes = publicationBloc.state.currentPublicacion!.likes;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  _CustonAppBarDetalle(publicacion: publicacion),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      _DescripcionDetalle(publicacion: publicacion),
                      _UbicacionDetalle(publicacion: publicacion),
                      const Divider(),
                      LikesCommentsDetails(
                          publicacion: publicacion, likes: likes!),
                      const Divider(),
                      _ListComentario(),
                      const SizedBox(
                        height: 80,
                      ),
                    ]),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _inputComentario(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputComentario() {
    final Map<String, dynamic> mapNews =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final publicacion = mapNews['publicacion'] as Publicacion;
    final publicationBloc = BlocProvider.of<PublicationBloc>(context);
    return Opacity(
      opacity: 1,
      child: Container(
        height: 50,
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: TextField(
                  controller: _textController,
                  onSubmitted: _handleSubmit,
                  onChanged: (comentario) {
                    setState(() {
                      if (comentario.isNotEmpty) {
                        _estaEscribiendo = true;
                      } else {
                        _estaEscribiendo = false;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Escribe un comentario',
                    filled: true,
                    fillColor: Colors.white30,
                    contentPadding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, top: 5.0, bottom: 5.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  maxLines: null, // Permite múltiples líneas de texto
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconTheme(
                data: IconThemeData(
                    color: Color(int.parse('0xFF${publicacion.color}'))),
                child: IconButton(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onPressed: _estaEscribiendo
                      ? () => {
                            _handleSubmit(_textController.text.trim()),
                            publicationBloc.add(CountCommentEvent(
                                publicationBloc.state.conuntComentarios + 1))
                          }
                      : null,
                  icon: const Icon(Icons.send),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _handleSubmit(String comentario) {
    if (comentario.isEmpty) return;
    _textController.clear();
    final createdAt = DateTime.now();
    final newComment = CommentPublication(
      comentario: comentario,
      nombre: authService.state.usuario!.nombre,
      fotoPerfil: 'da',
      createdAt: createdAt.toString(),
      uid: authService.state.usuario!.uid,
      likes: publicationBloc.state.comentarios!.where((element) {
        return element.uid == authService.state.usuario!.uid;
      }).length,
    );

    publicationBloc.add(AddCommentPublicationEvent(newComment));

    final List<String> comentarios = [
      ...publicationBloc.state.currentPublicacion!.comentarios ?? [],
      newComment.uid!
    ]; //agrega el comentario a la lista de comentarios

    publicationBloc.add(UpdatePublicationEvent(Publicacion(
      titulo: publicationBloc.state.currentPublicacion!.titulo,
      contenido: publicationBloc.state.currentPublicacion!.contenido,
      color: publicationBloc.state.currentPublicacion!.color,
      ciudad: publicationBloc.state.currentPublicacion!.ciudad,
      barrio: publicationBloc.state.currentPublicacion!.barrio,
      isPublic: publicationBloc.state.currentPublicacion!.isPublic,
      usuario: publicationBloc.state.currentPublicacion!.usuario,
      latitud: publicationBloc.state.currentPublicacion!.latitud,
      longitud: publicationBloc.state.currentPublicacion!.longitud,
      imgAlerta: publicationBloc.state.currentPublicacion!.imgAlerta,
      isLiked: publicationBloc.state.currentPublicacion!.isLiked,
      uid: publicationBloc.state.currentPublicacion!.uid,
      comentarios: comentarios,
      likes: publicationBloc.state.currentPublicacion!.likes,
      imagenes: publicationBloc.state.currentPublicacion!.imagenes,
      createdAt: publicationBloc.state.currentPublicacion!.createdAt,
      updatedAt: publicationBloc.state.currentPublicacion!.updatedAt,
      usuarioNombre: publicationBloc.state.currentPublicacion!.usuarioNombre,
    )));

    publicationBloc.add(CountCommentEvent(
        publicationBloc.state.conuntComentarios + 1)); //aumenta el contador
    setState(() {
      _estaEscribiendo = false;

      this.authService.socketService.socket.emit('comentario-publicacion', {
        'nombre': authService.state.usuario!.nombre,
        'mensaje': newComment.comentario,
        'fotoPerfil': authService.state.usuario!.img ?? 'S/N',
        'createdAt': createdAt.toString(),
        'para': publicationBloc.state.currentPublicacion!.uid!,
        'de': authService.state.usuario!.uid,
      });
    });
  }

  @override
  void dispose() {
    publicationBloc.add(const GetAllCommentsEvent([]));
    authService.socketService.socket.off('comentario-publicacion');
    authService.socketService.socket.off('join-room');
    publicationBloc.add(const ResetCommentPublicationEvent());

    super.dispose();
  }
}

class _ListComentario extends StatelessWidget {
  const _ListComentario({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final publicationBloc = BlocProvider.of<PublicationBloc>(context);
    return BlocBuilder<PublicationBloc, PublicationState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.comentariosP.isEmpty) {
          return const Center(
            child: Text('No hay comentarios'),
          );
        }

        final comentariosP = state.comentariosP;

        return ListView.builder(
          shrinkWrap: true,
          reverse: true,

          physics: const BouncingScrollPhysics(),
          itemCount: comentariosP.length,
          itemBuilder: (_, i) => comentariosP[i],
          // reverse: true,
        );
      },
    );
  }
}

class _UbicacionDetalle extends StatefulWidget {
  final Publicacion publicacion;

  const _UbicacionDetalle({Key? key, required this.publicacion})
      : super(key: key);

  @override
  State<_UbicacionDetalle> createState() => _UbicacionDetalleState();
}

class _UbicacionDetalleState extends State<_UbicacionDetalle> {
  String barrio = '';
  String locality = '';
  String ciudad = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final locationBloc = BlocProvider.of<LocationBloc>(context);
    final Map<String, dynamic> mapNews =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final publicacion = mapNews['publicacion'] as Publicacion;
    final searchBloc = BlocProvider.of<SearchBloc>(context);
    final mapBloc = BlocProvider.of<MapBloc>(context);
    final counterBloc = BlocProvider.of<NavigatorBloc>(context);
    LatLng? end;
    return Container(
      //aagregar un margen en el contenedor
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      // color: Color(0xFF6165FA),
      child: Row(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black26,
                width: 1.0,
                //color de fondo del contenedor
              ),
            ),
            child: Container(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
              color: Color(int.parse('0xFF${publicacion.color}')),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //mes y dia con icno de reloj y la de publicacion
                  Text(
                    DateFormat('MMMM d').format(DateTime.parse(
                        widget.publicacion.createdAt.toString())),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      const Icon(FontAwesomeIcons.clock,
                          size: 20, color: Colors.white),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        DateFormat('HH:mm').format(DateTime.parse(
                            widget.publicacion.createdAt.toString())),
                        style: const TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 6.5),
              decoration: const BoxDecoration(),

              // color: Color.fromARGB(255, 252, 81, 81),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    barrio,
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  Text(
                    ciudad,
                    style: const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            child: Container(
              height: 50,
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black26,
                  width: 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.mapLocationDot,
                    size: 20,
                    color: Color(int.parse('0xFF${publicacion.color}')),
                  ),
                  const Text(
                    'Ver mapa',
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ],
              ),
            ),
            onTap: () async {
              final start = locationBloc.state.lastKnownLocation;
              if (start == null) return;
              end = LatLng(publicacion.latitud, publicacion.longitud);
              if (end == null) return;
              searchBloc.add(OnActivateManualMarkerEvent());
              showLoadingMessage(context);
              final destination =
                  await searchBloc.getCoorsStartToEnd(start, end!);
              await mapBloc.drawRoutePolyline(destination);
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              counterBloc.add(const NavigatorIndexEvent(index: 0));
            },
          )
        ],
      ),
    );
  }

  void _getCurrentLocation() async {
    final double lat = widget.publicacion.latitud;
    final double lon = widget.publicacion.longitud;
    final List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
    // print(placemarks);
    if (placemarks.isNotEmpty) {
      final Placemark place = placemarks.first;
      barrio = place.locality ?? '';
      locality = place.subLocality ?? '';
      ciudad = place.administrativeArea ?? '';
    }

    setState(() {});
  }
}

// class from type SliverAppBar
class _CustonAppBarDetalle extends StatelessWidget {
  final Publicacion publicacion;
  const _CustonAppBarDetalle({required this.publicacion});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (publicacion.imagenes == null || publicacion.imagenes!.isEmpty) {
      return SliverAppBar(
        elevation: 1,
        backgroundColor: Color(int.parse('0xFF${publicacion.color}')),
        floating: false,
        pinned: true,
      );
    }

    return SliverAppBar(
      //color del appbar al regresar sobre negrea transparencia

      iconTheme: const IconThemeData(
        color: Colors.white,
        shadows: [
          Shadow(
            blurRadius: 18.0,
            color: Colors.black,
            offset: Offset(1.0, 1.0),
          ),
        ],
      ),
      elevation: 2,
      backgroundColor: Color(int.parse('0xFF${publicacion.color}')),
      expandedHeight: size.height * 0.40,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        title: Text(
          publicacion.titulo,
          style: const TextStyle(color: Colors.white),
        ),
        background: Swiper(
          pagination: const SwiperPagination(),
          itemCount: publicacion.imagenes!.length,
          itemBuilder: (BuildContext context, int index) {
            return Image.network(
              "${Environment.apiUrl}/uploads/publicaciones/${publicacion.uid!}?imagenIndex=${publicacion.imagenes![index]}",
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }
}

class _DescripcionDetalle extends StatefulWidget {
  const _DescripcionDetalle({required this.publicacion});

  final Publicacion publicacion;

  @override
  _DescripcionDetalleState createState() => _DescripcionDetalleState();
}

class _DescripcionDetalleState extends State<_DescripcionDetalle> {
  bool alertaAtendida = false;

  @override
  Widget build(BuildContext context) {
    final isAlertaAtendida = alertaAtendida;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // InkWell(
          //   //inkwell es para que se pueda hacer click en el texto y se pueda cambiar el estado
          //   onTap: () {
          //     setState(() {
          //       alertaAtendida = !alertaAtendida;
          //     });
          //   },
          //   borderRadius: BorderRadius.circular(5),
          //   child: Ink(
          //     decoration: BoxDecoration(
          //       color: isAlertaAtendida ? Colors.green[100] : Colors.red[100],
          //       borderRadius: BorderRadius.circular(5),
          //     ),
          //     padding: const EdgeInsets.all(10),
          //     child: Row(
          //       children: [
          //         Icon(
          //           isAlertaAtendida
          //               ? Icons.check_circle_outline
          //               : Icons.error_outline,
          //           size: 16,
          //           color: isAlertaAtendida ? Colors.green : Colors.red,
          //         ),
          //         const SizedBox(width: 5),
          //         Text(
          //           isAlertaAtendida
          //               ? 'Haz clic aquí si la alerta ha sido atendida'
          //               : 'Haz clic aquí si la alerta no ha sido atendida',
          //           style: TextStyle(
          //             color: isAlertaAtendida ? Colors.green : Colors.red,
          //             fontSize: 16,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //         const Spacer(),
          //       ],
          //     ),
          //   ),
          // ),
          const SizedBox(height: 10),
          Text(
            widget.publicacion.contenido,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
