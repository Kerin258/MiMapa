//
//  ContentView.swift
//  MiMapa
//
//  Ejercicio: Mapas y Permisos
//  Tópicos Avanzados de Aplicaciones Móviles
//

// Paso 1: frameworks para mapas (MapKit) y ubicación (CoreLocation)
import SwiftUI
import MapKit
import CoreLocation

// Un lugar predefinido que se puede mostrar en el mapa.
struct Lugar: Identifiable {
    let nombre: String
    let coordenada: CLLocationCoordinate2D
    var id: String { nombre }
}

struct ContentView: View {

    // Paso 2: centro del mapa (Centro Histórico de Campeche)
    static let centro = CLLocationCoordinate2D(latitude: 19.8463, longitude: -90.5372)

    // Paso 3: zoom del mapa (0 = máximo acercamiento; 180/360 = planeta entero)
    static let zoom = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)

    // Paso 4: vista inicial del mapa; @State hace que cualquier cambio redibuje la interfaz
    @State private var region = MKCoordinateRegion(center: ContentView.centro, span: ContentView.zoom)

    // Paso 7: lugares predefinidos y el lugar seleccionado en el Picker
    @State private var selection = "Centro Histórico"
    let lugares: [Lugar] = [
        Lugar(nombre: "Centro Histórico",
              coordenada: CLLocationCoordinate2D(latitude: 19.8463, longitude: -90.5372)),
        Lugar(nombre: "Puerta de Mar",
              coordenada: CLLocationCoordinate2D(latitude: 19.8476, longitude: -90.5388)),
        Lugar(nombre: "Puerta de Tierra",
              coordenada: CLLocationCoordinate2D(latitude: 19.8433, longitude: -90.5329)),
        Lugar(nombre: "Malecón",
              coordenada: CLLocationCoordinate2D(latitude: 19.8480, longitude: -90.5420)),
        Lugar(nombre: "Fuerte de San Miguel",
              coordenada: CLLocationCoordinate2D(latitude: 19.8297, longitude: -90.5574)),
        Lugar(nombre: "Fuerte de San José el Alto",
              coordenada: CLLocationCoordinate2D(latitude: 19.8649, longitude: -90.5163))
    ]

    // Paso 10: el LocationManager forma parte del estado de la vista
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        VStack {
            // Paso 7: selector para cambiar entre lugares
            Picker("Escoge un lugar", selection: $selection) {
                ForEach(lugares) { lugar in
                    Text(lugar.nombre).tag(lugar.nombre)
                }
            }
            .padding()
            .onChange(of: selection) { newValue in
                if let lugar = lugares.first(where: { $0.nombre == newValue }) {
                    region = MKCoordinateRegion(
                        center: lugar.coordenada,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                }
            }

            // Paso 5: vista Map ligada a la región; muestra el punto azul del usuario
            Map(coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: lugares) { lugar in
                MapMarker(coordinate: lugar.coordenada, tint: .red)
            }
            .edgesIgnoringSafeArea(.bottom)
            .overlay(alignment: .bottom) {
                HStack {
                    // Paso 6: botón que cambia la vista a otro lugar
                    Button("Siguiente lugar") {
                        let i = lugares.firstIndex(where: { $0.nombre == selection }) ?? 0
                        selection = lugares[(i + 1) % lugares.count].nombre
                    }
                    .buttonStyle(.borderedProminent)

                    // Paso 10: centrar el mapa en la ubicación del usuario
                    Button("Mi ubicación") {
                        region = locationManager.region
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
                .padding(.bottom, 30)
            }
        }
    }
}
