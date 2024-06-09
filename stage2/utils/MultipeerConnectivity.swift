//
//  MultipeerConnectivity.swift
//  conquery
//
//  Created by Kyrell Leano Siauw on 16/05/24.
//

import MultipeerConnectivity
extension Notification.Name {
    static let gameStateDidChange = Notification.Name("gameStateDidChange")
}

class MultipeerManager: NSObject, ObservableObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    // MARK: - Properties
    var pairingCode: String = ""
    let serviceType = "dreadscape"
    var myPeerId: MCPeerID?
    var advertiser: MCNearbyServiceAdvertiser?
    var browser: MCNearbyServiceBrowser?
    var session: MCSession?
    
    @Published var isLoading = false
    @Published var connectedPeer: MCPeerID?
    
    // Reference to the game controller
    var gameController: ModernGameController?
    
    override init() {
        super.init()
    }
    
    func activate() {
        // Execute on the main thread
        DispatchQueue.main.async {
            self.myPeerId = MCPeerID(displayName: self.pairingCode)
            self.session = MCSession(peer: self.myPeerId!, securityIdentity: nil, encryptionPreference: .required)
            self.advertiser = MCNearbyServiceAdvertiser(peer: self.myPeerId!, discoveryInfo: nil, serviceType: self.serviceType)
            self.browser = MCNearbyServiceBrowser(peer: self.myPeerId!, serviceType: self.serviceType)
            
            self.session?.delegate = self
            self.advertiser?.delegate = self
            self.browser?.delegate = self
            
            self.advertiser?.startAdvertisingPeer()
            self.browser?.startBrowsingForPeers()
        }
    }
    
    // MARK: Methods
    func invitePeer(_ peer: MCPeerID) {
        guard let browser = browser, let session = session else { return }
        
        DispatchQueue.main.async {
            self.isLoading = true
            browser.invitePeer(peer, to: session, withContext: nil, timeout: 30)
        }
    }
    
    func changeGameState(_ state: String) {
        // Broadcast the state change to peers
        if let data = state.data(using: .utf8) {
            do {
                try self.session!.send(data, toPeers: self.session!.connectedPeers, with: .reliable)
            } catch {
                print("Error sending game state: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - MCNearbyServiceBrowserDelegate
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            if peerID.displayName == self.pairingCode {
                self.invitePeer(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            // Handle lost peer
        }
    }
    
    // MARK: - MCNearbyServiceAdvertiserDelegate
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
            invitationHandler(true, self.session)
        }
    }
    
    // MARK: - MCSessionDelegate
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.connectedPeer = peerID
                self.isLoading = false
            case .notConnected:
                self.connectedPeer = nil
                self.isLoading = false
                self.session?.disconnect()
            default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Handle received data
        if let state = String(data: data, encoding: .utf8) {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .gameStateDidChange, object: state)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Handle receiving a stream
        fatalError("This method has not been implemented")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Handle the start of receiving a resource
        fatalError("This method has not been implemented")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Handle finishing receiving a resource
        fatalError("This method has not been implemented")
    }
    
    func session(_ session: MCSession, didReceive certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}
