import 'package:animate_do/animate_do.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps_adv/blocs/blocs.dart';
import 'package:flutter_maps_adv/blocs/search/search_bloc.dart';
import 'package:flutter_maps_adv/screens/alerts_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BtnReport extends StatelessWidget {
  const BtnReport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return state.displayManualMarker
            ? const _BtnCancelar()
            : FadeInUp(
                duration: const Duration(milliseconds: 300),
                child: const _BtnReport());
      },
    );
  }
}

class _BtnReport extends StatelessWidget {
  const _BtnReport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
            width: width * 0.95,
            height: 40,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                //largor del boton

                backgroundColor: const Color(0xFF6165FA),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                // padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              ),
              onPressed: () {
                // AlertasScreen.routeName
                Navigator.pushNamed(context, AlertsScreen.routeName);
              },
              //icono de una campana de aleerta
              icon: const Icon(FontAwesomeIcons.fire,
                  size: 16, color: Colors.white),
              label: const Text("REPORTAR",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _BtnCancelar extends StatelessWidget {
  const _BtnCancelar({super.key});

  @override
  Widget build(BuildContext context) {
    MapBloc mapBloc = BlocProvider.of<MapBloc>(context);
    double width = MediaQuery.of(context).size.width;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
            width: width * 0.25,
            height: 40,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                //largor del boton

                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                // padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              ),
              onPressed: () {
                mapBloc.add(OnMapMovedEvent());
                BlocProvider.of<SearchBloc>(context)
                    .add(OnDeactivateManualMarkerEvent());
              },
              //icono de una campana de aleerta
              icon: const Icon(FontAwesomeIcons.times,
                  size: 16, color: Colors.white),
              label: const Text("CANCELAR",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
