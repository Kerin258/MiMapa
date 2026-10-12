//
//  LocationManager.swift
//  MiMapa
//
//  Created by Jose Aguilar on 15/10/24.
//  Extendido para publicar el estado del permiso y la última ubicación recibida.
//

import MapKit
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.847707, longitude: -90.476276),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    // Agregado: estado del permiso de ubicación y última posición real del usuario
    @Published var estadoPermiso: CLAuthorizationStatus = .notDetermined
    @Published var ultimaUbicacion: CLLocation?

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.ultimaUbicacion = location
        self.region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }

    // Agregado: se ejecuta cuando el usuario acepta o rechaza el permiso
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.estadoPermiso = manager.authorizationStatus
    }
}
