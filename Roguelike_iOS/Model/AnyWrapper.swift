// A simple way to get Codable comformance for [Any] and [String: Any] types,
// where Any can be any basic type as well as nested arrays and dictionaries.
//
// Use:
// let associativeStorage = [String: Any]()
// First wrap it
//      let wrappedAssociativeStorage = try AnyWrapper.wrapperFor(associativeStorage)
// Then encode it using:
//      let data = try encoder.encode(associativeStorage)
//
// Decode it using:
//      let decodedWrappedAssociativeStorage = try decoder.decode(AnyWrapper.self, from: data)
// And get back your previous dictionary
//      let decodedAssociativeStorage = decodedWrappedAssociativeStorage.value
//
// Supports:
// Basic types:
//  - String
//  - Int
//  - Double
//  - UUID
//
// Collections:
//  - Array<Any> where Any is a AnyWrapper supported type
//  - Dictionary<String: Any> where Any is a AnyWrapper supported type
//
// You can add custom types, but you will need to do so at a per type basis, just to be sure that you
// know the type when unwrapping.

import Foundation

enum AnyWrapper: Codable {
    enum AnyWrapperErrors: Error {
        case cannotConvertError
    }
    
    enum CodingKeys: CodingKey {
        case type, value
    }
    
    case wrappedNull
    case string(value: String)
    case bool(value: Bool)
    case int(value: Int)
    case double(value: Double)
    case uuid(value: UUID)
    case array(value: [AnyWrapper])
    case coord(value: Coord)
    case stringlyTypedDict(value: [String: AnyWrapper])
    case equipmentSlotEntityDict(value: [EquipmentSlot: AnyWrapper])
    case coordSet(value: Set<Coord>)
    case entity(value: RLEntity)
    case equipmentSlot(value: EquipmentSlot)
    //case optionalEntity(value: RLEntity?)
    
    static func wrapperFor(_ value: Any) throws -> AnyWrapper {
        if value == nil {
            return .wrappedNull
        } else if let v = value as? String {
            return .string(value: v)
        } else if let v = value as? Bool {
            return .bool(value: v)
        } else if let v = value as? Int {
            return .int(value: v)
        } else if let v = value as? Double {
            return .double(value: v)
        } else if let v = value as? UUID {
            return .uuid(value: v)
        } else if let v = value as? Coord {
            return .coord(value: v)
        } else if let v = value as? [Any] {
            let wrappedArray = v.compactMap { item in try? AnyWrapper.wrapperFor(item)}
            return .array(value: wrappedArray)
        } else if let v = value as? [String: Any] {
            let wrappedDict = try v.mapValues { itemValue in try AnyWrapper.wrapperFor(itemValue) }
            return .stringlyTypedDict(value: wrappedDict)
        } else if let v = value as? [EquipmentSlot: RLEntity?] {
            let wrappedDict = try v.mapValues { itemValue -> AnyWrapper in
                if let notNilItemValue = itemValue {
                    return try AnyWrapper.wrapperFor(notNilItemValue)
                } else {
                    return AnyWrapper.wrappedNull
                }
            }
            return .equipmentSlotEntityDict(value: wrappedDict)
        } else if let v = value as? Set<Coord> {
            return .coordSet(value: v)
        } else if let v = value as? RLEntity {
            return .entity(value: v)
        } else if let v = value as? EquipmentSlot {
            return .equipmentSlot(value: v)
        } else {
            throw AnyWrapperErrors.cannotConvertError
        }
    }
    
    var value: Any {
        switch self {
        case .wrappedNull:
            return self
        case .string(let value):
            return value
        case .bool(let value):
            return value
        case .int(let value):
            return value
        case .double(let value):
            return value
        case .uuid(let value):
            return value
        case .coord(let value):
            return value
        case .entity(let value):
            return value
        case .array(let array):
            return array.map {wrappedItem in wrappedItem.value}
        case .stringlyTypedDict(let dict):
            let unwrappedDict = dict.mapValues { itemValue in itemValue.value}
            return unwrappedDict
        case .equipmentSlotEntityDict(let dict):
            let unwrappedDict = dict.mapValues { itemValue -> RLEntity? in
                switch itemValue {
                case .wrappedNull:
                    return nil
                default:
                    return itemValue.value as? RLEntity
                }
            }
            return unwrappedDict
        case .coordSet(let set):
            return set
        case .equipmentSlot(let value):
            return value
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .wrappedNull:
            try container.encode("wrappedNull", forKey: .type)
        case .string(let value):
            try container.encode("string", forKey: .type)
            try container.encode(value, forKey: .value)
        case .bool(let value):
            try container.encode("bool", forKey: .type)
            try container.encode(value, forKey: .value)
        case .int(let value):
            try container.encode("int", forKey: .type)
            try container.encode(value, forKey: .value)
        case .double(let value):
            try container.encode("double", forKey: .type)
            try container.encode(value, forKey: .value)
        case .uuid(let value):
            try container.encode("uuid", forKey: .type)
            try container.encode(value, forKey: .value)
        case .coord(let value):
            try container.encode("coord", forKey: .type)
            try container.encode(value, forKey: .value)
        case .entity(let value):
            try container.encode("entity", forKey: .type)
            try container.encode(value, forKey: .value)
        case .array(let array):
            try container.encode("array", forKey: .type)
            try container.encode(array, forKey: .value)
        case .stringlyTypedDict(let dict):
            try container.encode("stringlyTypedDict", forKey: .type)
            try container.encode(dict, forKey: .value)
        case .coordSet(let set):
            try container.encode("coordSet", forKey: .type)
            try container.encode(set, forKey: .value)
        case .equipmentSlotEntityDict(let dict):
            try container.encode("equipmentSlotEntityDict", forKey: .type)
            try container.encode(dict, forKey: .value)
        case .equipmentSlot(let value):
            try container.encode("equipmentSlot", forKey: .type)
            try container.encode(value, forKey: .value)
        }
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let type = try values.decode(String.self, forKey: .type)
        
        switch type {
        case "wrappedNull":
            self = .wrappedNull
        case "string":
            let v = try values.decode(String.self, forKey: .value)
            self = .string(value: v)
        case "bool":
            let v = try values.decode(Bool.self, forKey: .value)
            self = .bool(value: v)
        case "int":
            let v = try values.decode(Int.self, forKey: .value)
            self = .int(value: v)
        case "double":
            let v = try values.decode(Double.self, forKey: .value)
            self = .double(value: v)
        case "uuid":
            let v = try values.decode(UUID.self, forKey: .value)
            self = .uuid(value: v)
        case "coord":
            let v = try values.decode(Coord.self, forKey: .value)
            self = .coord(value: v)
        case "entity":
            let v = try values.decode(RLEntity.self, forKey: .value)
            self = .entity(value: v)
        case "array":
            let v = try values.decode([AnyWrapper].self, forKey: .value)
            self = .array(value: v)
        case "stringlyTypedDict":
            let v = try values.decode([String: AnyWrapper].self, forKey: .value)
            self = .stringlyTypedDict(value: v)
        case "coordSet":
            let v = try values.decode(Set<Coord>.self, forKey: .value)
            self = .coordSet(value: v)
        case "equipmentSlotEntityDict":
            let decodedDict = try values.decode([EquipmentSlot: AnyWrapper].self, forKey: .value)
            self = .equipmentSlotEntityDict(value: decodedDict)
        case "equipmentSlot":
            let v = try values.decode(EquipmentSlot.self, forKey: .value)
            self = .equipmentSlot(value: v)
        default:
            throw AnyWrapperErrors.cannotConvertError
        }
        
    }
}
