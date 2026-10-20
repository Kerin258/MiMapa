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
              coordenada: CLLocationCoordinate2D(latitude: 19.8413932, longitude: -90.5360358)),
        Lugar(nombre: "Malecón",
              coordenada: CLLocationCoordinate2D(latitude: 19.8478906, longitude: -90.5397704)),
        Lugar(nombre: "Fuerte de San Miguel",
              coordenada: CLLocationCoordinate2D(latitude: 19.824654, longitude: -90.56867)),
        Lugar(nombre: "Fuerte de San José el Alto",
              coordenada: CLLocationCoordinate2D(latitude: 19.8604541, longitude: -90.5106048))
    ]

    // Paso 10: el LocationManager forma parte del estado de la vista
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Paso 7: selector para cambiar entre lugares
                Picker("Escoge un lugar", selection: $selection) {
                    ForEach(lugares) { lugar in
                        Text(lugar.nombre).tag(lugar.nombre)
                    }
                }
                .padding(.vertical, 6)
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
                        .disabled(locationManager.ultimaUbicacion == nil)
                    }
                    .padding(.bottom, 12)
                }

                // Panel de estado: permiso y posición del usuario en tiempo real
                VStack(alignment: .leading, spacing: 4) {
                    Label(textoPermiso, systemImage: iconoPermiso)
                        .foregroundStyle(colorPermiso)
                    if let ubicacion = locationManager.ultimaUbicacion {
                        Text(String(format: "Lat: %.5f   Lon: %.5f",
                                    ubicacion.coordinate.latitude,
                                    ubicacion.coordinate.longitude))
                            .monospacedDigit()
                        Text("Actualizado: \(ubicacion.timestamp.formatted(date: .omitted, time: .standard))")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Esperando la ubicación del usuario…")
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.bar)
            }
            .navigationTitle("Mapas de Campeche")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // Texto, ícono y color según el estado del permiso de ubicación
    private var textoPermiso: String {
        switch locationManager.estadoPermiso {
        case .authorizedWhenInUse, .authorizedAlways: return "Permiso de ubicación: concedido"
        case .denied: return "Permiso de ubicación: denegado"
        case .restricted: return "Permiso de ubicación: restringido"
        default: return "Permiso de ubicación: pendiente"
        }
    }

    private var iconoPermiso: String {
        switch locationManager.estadoPermiso {
        case .authorizedWhenInUse, .authorizedAlways: return "checkmark.circle.fill"
        case .denied, .restricted: return "xmark.circle.fill"
        default: return "questionmark.circle.fill"
        }
    }

    private var colorPermiso: Color {
        switch locationManager.estadoPermiso {
        case .authorizedWhenInUse, .authorizedAlways: return .green
        case .denied, .restricted: return .red
        default: return .orange
        }
    }
}
