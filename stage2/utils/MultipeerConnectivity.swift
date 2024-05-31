//
//  MultipeerConnectivity.swift
//  conquery
//
//  Created by Kyrell Leano Siauw on 16/05/24.
//

import MultipeerConnectivity

class MultipeerManager: NSObject, ObservableObject, MCSessionDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    // MARK: - Properties
    let pairingCode: String = ""
    let serviceType = "dreadscape"
    var myPeerId: MCPeerID
    var advertiser: MCNearbyServiceAdvertiser
    var browser: MCNearbyServiceBrowser
    var session: MCSession
    
    @Published var isLoading = false
    @Published var connectedPeer: MCPeerID?
    
    override init() {
        myPeerId = MCPeerID(displayName: pairingCode)
        session = MCSession(peer: myPeerId, securityIdentity: nil, encryptionPreference: .required)
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        browser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        super.init()
        
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
        
        advertiser.startAdvertisingPeer()
        browser.startBrowsingForPeers()
    }
    
    // MARK: Methods
    func invitePeer(_ peer: MCPeerID) {
        Task {
            isLoading = true
            browser.invitePeer(peer, to: session, withContext: nil, timeout: 30)
        }
    }
    
    // MARK: - MCNearbyServiceBrowserDelegate
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            // If username match, connect to the peer
            if peerID.displayName == self.pairingCode {
                self.invitePeer(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            
        }
    }
    
    // MARK: - MCNearbyServiceAdvertiserDelegate
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        DispatchQueue.main.async {
           // Accept the invitation
            invitationHandler(true, self.session)
            // Stop searching for peers
            self.browser.stopBrowsingForPeers()
            // Stop advertising
            self.advertiser.stopAdvertisingPeer()
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
        // This is a security feature that you can implement to authenticate the connecting peers
        certificateHandler(true) // Accept the certificate for now; implement proper checks as needed for your app
    }
}
