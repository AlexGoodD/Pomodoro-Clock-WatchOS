//
//  ContentView.swift
//  Reloj Pomodoro Watch App
//
//  Created by Alejandro on 11/08/24.
//

import SwiftUI
import AVFoundation
import WatchKit

struct ContentView: View {
    @State private var tiempoRestante = 1500 // 1500 segundos (25 min)
    
    @State private var tiempoTrabajo = 1500 // 1500 segundos (5 min)
    @State private var tiempoDescanso = 300 // 300 segundos (5 min)
    @State private var tiempoDescansoLargo = 900 // 900 segundos (15 min)
    @State private var enTrabajo = true
    @State private var enDescanso = false
    
    @State private var cicloContador = 0 // No. veces que se hace un ciclo
    @State private var progresoActual: CGFloat = 0.0 // Progreso actual
    @State private var temporizador: Timer?
    
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        ZStack {
            
            // Fondo blanco
            RoundedRectangle(cornerRadius: 32.0)
                .fill(Color.white)
                .frame(width: 200, height: 250)
                .padding(.bottom, 35)

            // Fondo borde progreso
            RoundedRectangle(cornerRadius: 40.0)
                .stroke(enTrabajo ? Color.red.opacity(0.2) : Color.blue.opacity(0.2), lineWidth: 15)
                .frame(width: 190, height: 235)
                .padding(.bottom, 25)
            
            // Borde progreso
            RoundedRectangle(cornerRadius: 40.0)
                .trim(from: 0.0, to: progresoActual)
                .stroke(enTrabajo ? Color.red : Color.blue, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
                .frame(width: 235, height: 190)
                .padding(.bottom, 25)
                .animation(.linear(duration: 1), value: progresoActual)

            // Elementos dentro del reloj
            VStack {
                
                
                
                RollingNumber(targetValue: $cicloContador)
                    .font(.system(size: 20))
                    .background(enTrabajo ? Color.red : Color.blue.opacity(0.5))
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .padding(.bottom, 10)

                Text("\(formatearTiempo(tiempoRestante))")
                    .font(.system(size: 40, weight: .semibold, design: .monospaced))
                    .foregroundColor(.brown)
                    .padding(.bottom, 10)
                
                Text("Created by Alex")
                    .font(.system(size: 5, weight: .semibold, design: .monospaced))
                    .foregroundColor(.brown)

                HStack {
                    
                    Spacer()
                    
                    Button(action: temporizador == nil ? iniciarTemporizador : detenerTemporizador) {
                        Image(systemName: temporizador == nil ? "play.fill" : "pause.fill")
                            .font(.system(size: 15))
                            .padding(10)
                            .background(enTrabajo ? Color.red : Color.blue.opacity(0.5))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()

                    Button(action: terminarTemporizador) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15))
                            .padding(10)
                            .background(enTrabajo ? Color.red : Color.blue.opacity(0.5))
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                .padding(.bottom, 30)
            }
            
        }
        .onAppear {
            progresoActual = calcularProgreso()
        }
    }
    
    // Formato de números

    func formatearTiempo(_ segundosTotales: Int) -> String {
        let minutos = segundosTotales / 60
        let segundos = segundosTotales % 60
        return String(format: "%02d:%02d", minutos, segundos)
    }

    func iniciarTemporizador() {
        
        alertaTemporizador()
        pulsacionHaptica()
        
        if temporizador != nil { return }
        
        temporizador = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if tiempoRestante > 0 {
                tiempoRestante -= 1
                progresoActual = calcularProgreso()
            } else {
                if enTrabajo {
                    enTrabajo.toggle()
                    enDescanso = true
                    
                    alertaFinTemporizador()

                    if cicloContador < 9 {
                        tiempoRestante = tiempoDescanso
                    }
                } else {
                    enTrabajo.toggle()
                    enDescanso = false
                    
                    alertaTemporizador()
                    
                    if cicloContador < 9 {
                        cicloContador += 1
                    }

                    tiempoRestante = tiempoTrabajo
                }
                
                if !enTrabajo {
                    if cicloContador == 4 || cicloContador == 8 {
                        tiempoRestante = tiempoDescansoLargo
                    }
                }

                progresoActual = 0.0
                
                if cicloContador == 9 {
                    temporizador?.invalidate()
                    temporizador = nil
                }
            }
        }
    }

    func detenerTemporizador() {
        pulsacionHaptica()
        temporizador?.invalidate()
        temporizador = nil
    }

    func terminarTemporizador() {
        pulsacionHaptica()
        detenerTemporizador()
        tiempoRestante = tiempoTrabajo
        enTrabajo = true
        progresoActual = 0.0
        cicloContador = 0
    }

    func calcularProgreso() -> CGFloat {
        let tiempoTotal: Int
        
        if enTrabajo {
            tiempoTotal = tiempoTrabajo
        } else {
            tiempoTotal = (cicloContador == 4 || cicloContador == 8) ? tiempoDescansoLargo : tiempoDescanso
        }
        
        return CGFloat(tiempoTotal - tiempoRestante) / CGFloat(tiempoTotal)
    }
    
    func pulsacionHaptica(){
        let dispositivo = WKInterfaceDevice.current()
                dispositivo.play(.click)
    }
    
    
    func alertaTemporizador() {
        guard let url = Bundle.main.url(forResource: "alertstart", withExtension: "MP3") else {
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error al reproducir el sonido: \(error.localizedDescription)")
        }
    }
    
    func alertaFinTemporizador() {
        guard let url = Bundle.main.url(forResource: "alertend", withExtension: "MP3") else {
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error al reproducir el sonido: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
}
