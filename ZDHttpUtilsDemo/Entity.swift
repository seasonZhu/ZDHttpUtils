//
//  Entity.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2018/10/11.
//  Copyright © 2018 season. All rights reserved.
//

import Foundation
import ObjectMapper


/// 这个根的没有使用 使用的是泛型装配
struct U17Root: Mappable {
    var code : Int?
    var data : U17Data?
    
    mutating func mapping(map: Map) {
        code <- map["code"]
        data <- map["data"]
        
    }
    
    init?(map: Map) {
        
    }
}

struct U17Data: Mappable{
    
    var message : String?
    var returnData : ReturnData?
    var stateCode : Int?
    
    init?(map: Map){}

    
    mutating func mapping(map: Map) {
        message <- map["message"]
        returnData <- map["returnData"]
        stateCode <- map["stateCode"]
    }
}

struct ReturnData: Mappable{
    
    var comicLists : [ComicList]?
    var editTime : String?
    var galleryItems : [GalleryItem]?
    var textItems : [AnyObject]?
    
    init?(map: Map){}
    
    mutating func mapping(map: Map) {
        comicLists <- map["comicLists"]
        editTime <- map["editTime"]
        galleryItems <- map["galleryItems"]
        textItems <- map["textItems"]
        
    }
}

struct GalleryItem: Mappable{
    
    var content : String?
    var cover : String?
    var ext : [Ext]?
    var id : Int?
    var linkType : Int?
    var title : String?
    
    init?(map: Map){}
    
    mutating func mapping(map: Map) {
        content <- map["content"]
        cover <- map["cover"]
        ext <- map["ext"]
        id <- map["id"]
        linkType <- map["linkType"]
        title <- map["title"]
        
    }
}

struct Ext: Mappable{
    
    var key : String?
    var val : String?
    
    init?(map: Map){}

    mutating func mapping(map: Map) {
        key <- map["key"]
        val <- map["val"]
    }
}

struct ComicList: Mappable {
    
    var argName : String?
    var argType : Int?
    var argValue : Int?
    var canedit : Int?
    var comicType : Int?
    var comics : [Comic]?
    var descriptionField : String?
    var itemTitle : String?
    var newTitleIconUrl : String?
    var sortId : String?
    var titleIconUrl : String?
    
    init?(map: Map){}
    
    mutating func mapping(map: Map) {
        argName <- map["argName"]
        argType <- map["argType"]
        argValue <- map["argValue"]
        canedit <- map["canedit"]
        comicType <- map["comicType"]
        comics <- map["comics"]
        descriptionField <- map["description"]
        itemTitle <- map["itemTitle"]
        newTitleIconUrl <- map["newTitleIconUrl"]
        sortId <- map["sortId"]
        titleIconUrl <- map["titleIconUrl"]
        
    }
}

struct Comic: Mappable{
    
    var authorName : String?
    var comicId : Int?
    var cornerInfo : String?
    var cover : String?
    var descriptionField : String?
    var isVip : Int?
    var name : String?
    var shortDescription : String?
    var subTitle : String?
    var tags : [String]?
    
    init?(map: Map){}
    
    mutating func mapping(map: Map) {
        authorName <- map["author_name"]
        comicId <- map["comicId"]
        cornerInfo <- map["cornerInfo"]
        cover <- map["cover"]
        descriptionField <- map["description"]
        isVip <- map["is_vip"]
        name <- map["name"]
        shortDescription <- map["short_description"]
        subTitle <- map["subTitle"]
        tags <- map["tags"]
        
    }
}
