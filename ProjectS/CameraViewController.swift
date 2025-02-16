import UIKit
import AVFoundation
import Vision

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var detectionOverlay: CALayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }

    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high

        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Câmera não encontrada")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            print("Erro ao configurar a câmera: \(error)")
            return
        }

        // Configura a camada de visualização
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Configura a saída de vídeo para processamento de frames
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(videoOutput)

        // Inicia a captura de vídeo
        captureSession.startRunning()

        // Camada para desenhar as detecções
        detectionOverlay = CALayer()
        detectionOverlay.bounds = view.layer.bounds
        detectionOverlay.position = view.layer.position
        view.layer.addSublayer(detectionOverlay)
    }

    // Processa cada frame capturado pela câmera
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectHumanBodyPoseRequest { [weak self] request, error in
            if let error = error {
                print("Erro ao detectar partes do corpo: \(error)")
                return
            }
            self?.processBodyPoseResults(request.results)
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Erro ao processar a requisição: \(error)")
        }
    }

    // Processa os resultados da detecção
    private func processBodyPoseResults(_ results: [Any]?) {
        guard let observations = results as? [VNHumanBodyPoseObservation] else { return }

        DispatchQueue.main.async {
            self.detectionOverlay.sublayers = nil // Limpa detecções anteriores

            for observation in observations {
                self.drawBodyParts(observation)
            }
        }
    }

    // Desenha as partes do corpo detectadas
    private func drawBodyParts(_ observation: VNHumanBodyPoseObservation) {
        let joints = try? observation.recognizedPoints(.all)

        joints?.forEach { (joint, point) in
            guard point.confidence > 0.1 else { return }

            let pointInView = previewLayer.layerPointConverted(fromCaptureDevicePoint: point.location)
            let textLayer = CATextLayer()
            textLayer.string = joint.rawValue
            textLayer.fontSize = 12
            textLayer.foregroundColor = UIColor.red.cgColor
            textLayer.frame = CGRect(x: pointInView.x, y: pointInView.y, width: 100, height: 20)
            detectionOverlay.addSublayer(textLayer)
        }
    }
}
