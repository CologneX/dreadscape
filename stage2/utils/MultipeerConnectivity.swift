//
//  MultipeerConnectivity.swift
//  conquery
//
//  Created by Kyrell Leano Siauw on 16/05/24.
//

import MultipeerConnectivity

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
    
    override init() {
        super.init()
    }
    
    func activate() {
        guard session == nil else { return }
        myPeerId = MCPeerID(displayName: pairingCode)
        session = MCSession(peer: myPeerId!, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerId!, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: myPeerId!, serviceType: serviceType)
        
        session?.delegate = self
        advertiser?.delegate = self
        browser?.delegate = self
        
        advertiser?.startAdvertisingPeer()
        browser?.startBrowsingForPeers()
    }
    
    // MARK: Methods
    func invitePeer(_ peer: MCPeerID) {
        guard let browser = browser, let session = session else { return }
        
        Task {
            isLoading = true
            browser.invitePeer(peer, to: session, withContext: nil, timeout: 30)
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
            self.browser?.stopBrowsingForPeers()
        }
    }
    
    // MARK: - MCSessionDelegate
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
//                print("""
//                    Connected to \(peerID.displayName)
//                    """)
                self.connectedPeer = peerID
                self.isLoading = false
            case .notConnected:
//                print("""
//                    Disconnected from \(peerID.displayName)
//                    """)
                self.connectedPeer = nil
                self.isLoading = false
            default:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Handle receiving data
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Handle receiving a stream
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Handle the start of receiving a resource
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Handle finishing receiving a resource
    }
    
    func session(_ session: MCSession, didReceive certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}
