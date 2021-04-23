/*
 * 이 파일은 사용자의 token을 저장하기 위한 파일입니다.
 * token을 Keychain을 사용하여 암호화합니다.
 */

import UIKit
import Security

class Keychain {
    
    static func save(key: String, data: Data) -> Bool {
        let query = [
            kSecClass        : kSecClassGenericPassword ,
            kSecAttrAccount  : key,
            kSecValueData    : data ] as [CFString : Any]
        
        SecItemDelete(query as CFDictionary)
        
        let status: OSStatus = SecItemAdd(query as CFDictionary, nil)
        
        return status == errSecSuccess
    }
    
    static func load(key: String) -> Data? {
        let query = [
            kSecClass        : kSecClassGenericPassword,
            kSecAttrAccount  : key,
            kSecReturnData   : kCFBooleanTrue as Any,
            kSecMatchLimit   : kSecMatchLimitOne ] as [CFString : Any]
        
        var dataTypeRef: AnyObject?
        let status = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        
        if status == errSecSuccess {
            if let data = dataTypeRef as! Data? {
                return data
            }
        }
        return nil
    }
    
    static func delete(key: String) -> Bool {
        let query = [
            kSecClass        : kSecClassGenericPassword,
            kSecAttrAccount  : key ] as [CFString : Any]
        
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        
        return status == errSecSuccess
    }
    
    
//    static func clear() -> Bool {
//        let query = [ kSecClass as String : kSecClassGenericPassword ]
//
//        let status: OSStatus = SecItemDelete(query as CFDictionary)
//
//        return status == errSecSuccess
//    }
    
}
