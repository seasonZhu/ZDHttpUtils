//
//  CodableEntity.swift
//  ZDHttpUtilsDemo
//
//  Created by season on 2019/2/22.
//  Copyright © 2019 season. All rights reserved.
//

import Foundation

/*
 论为什么Swift没有比较的JSON转模型的第三方 答Swift自带的Codable协议 就已经足够毁天灭地
 */

class CoableU17Root : Codable {
    
    var code : Int?
    var data : CoableU17Data?
    
    
//    enum CodingKeys: String, CodingKey {
//        case code = "code"
//        case data = "data"
//    }
//
//    required init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        code = try values.decodeIfPresent(Int.self, forKey: .code)
//        data = try values.decodeIfPresent(CoableU17Data.self, forKey: .data)
//    }
}

class CoableU17Data : Codable {
    
    var message : String?
    var returnData : CoableReturnData?
    var stateCode : Int?
    
    
//    enum CodingKeys: String, CodingKey {
//        case message = "message"
//        case returnData = "returnData"
//        case stateCode = "stateCode"
//    }
//    required init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        message = try values.decodeIfPresent(String.self, forKey: .message)
//        returnData = try values.decodeIfPresent(CoableReturnData.self, forKey: .returnData)
//        stateCode = try values.decodeIfPresent(Int.self, forKey: .stateCode)
//    }
    
    
}

class CoableReturnData : Codable {
    
    var comicLists : [CodableComicList]? {
        didSet {
            // 在init方法中赋值 不会走didSet的观察器,记住,所以涉及textItems的赋值,只能在init里面做了
            if comicLists?.count ?? 0 > 1 {
                isMoreThanOneComic = true
            }else {
                isMoreThanOneComic = false
            }
        }
    }
    var editTime : String? {
        didSet {
            // 在init方法中赋值 不会走didSet的观察器,记住,所以涉及textItems的赋值,只能在init里面做了
            //textItems = [10]
        }
    }
    var galleryItems : [CoableGalleryItem]?
    //var textItems : [AnyObject]?
    
    /// 这个是我自定义的
    var isMoreThanOneComic: Bool
    
    
    enum CodingKeys: String, CodingKey {
        case comicLists = "comicLists"
        case editTime = "editTime"
        case galleryItems = "galleryItems"
        //case textItems = "textItems"
    }
    
    /*
     如果模型里面有自定义的属性
     也就是根据从服务器获取JSON推导出来的其他属性赋值的时候
     需要写出Decodable协议实现的完整方法,注意 将init() {}也声明出来,否者你根本没有一个正常的初始化方法可以用
     */
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        comicLists = try values.decodeIfPresent([CodableComicList].self, forKey: .comicLists)
        editTime = try values.decodeIfPresent(String.self, forKey: .editTime)
        galleryItems = try values.decodeIfPresent([CoableGalleryItem].self, forKey: .galleryItems)
        //textItems = try values.decodeIfPresent([comicLists].self, forKey: .textItems)
        if let comicLists = comicLists, comicLists.count > 1 {
            isMoreThanOneComic = true
        }else {
            isMoreThanOneComic = false
        }
    }
    
    
}

class CoableGalleryItem : Codable {
    
    var content : String?
    var cover : String?
    var ext : [CodableExt]?
    var id : Int?
    var linkType : Int?
    var title : String?
    
    
//    enum CodingKeys: String, CodingKey {
//        case content = "content"
//        case cover = "cover"
//        case ext = "ext"
//        case id = "id"
//        case linkType = "linkType"
//        case title = "title"
//    }
//    required init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        content = try values.decodeIfPresent(String.self, forKey: .content)
//        cover = try values.decodeIfPresent(String.self, forKey: .cover)
//        ext = try values.decodeIfPresent([CodableExt].self, forKey: .ext)
//        id = try values.decodeIfPresent(Int.self, forKey: .id)
//        linkType = try values.decodeIfPresent(Int.self, forKey: .linkType)
//        title = try values.decodeIfPresent(String.self, forKey: .title)
//    }
    
    
}

class CodableExt : Codable {
    
    var key : String?
    var val : String?
    
    
//    enum CodingKeys: String, CodingKey {
//        case key = "key"
//        case val = "val"
//    }
//    required init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        key = try values.decodeIfPresent(String.self, forKey: .key)
//        val = try values.decodeIfPresent(String.self, forKey: .val)
//    }
    
    
}

class CodableComicList : Codable {
    
    var argName : String?
    var argType : Int?
    var argValue : Int?
    var canedit : Int?
    var comicType : Int?
    var comics : [CodableComic]?
    var descriptionField : String?
    var itemTitle : String?
    var newTitleIconUrl : String?
    var sortId : String?
    var titleIconUrl : String?
    
    
//    enum CodingKeys: String, CodingKey {
//        case argName = "argName"
//        case argType = "argType"
//        case argValue = "argValue"
//        case canedit = "canedit"
//        case comicType = "comicType"
//        case comics = "comics"
//        case descriptionField = "description"
//        case itemTitle = "itemTitle"
//        case newTitleIconUrl = "newTitleIconUrl"
//        case sortId = "sortId"
//        case titleIconUrl = "titleIconUrl"
//    }
//    required init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        argName = try values.decodeIfPresent(String.self, forKey: .argName)
//        argType = try values.decodeIfPresent(Int.self, forKey: .argType)
//        argValue = try values.decodeIfPresent(Int.self, forKey: .argValue)
//        canedit = try values.decodeIfPresent(Int.self, forKey: .canedit)
//        comicType = try values.decodeIfPresent(Int.self, forKey: .comicType)
//        comics = try values.decodeIfPresent([CodableComic].self, forKey: .comics)
//        descriptionField = try values.decodeIfPresent(String.self, forKey: .descriptionField)
//        itemTitle = try values.decodeIfPresent(String.self, forKey: .itemTitle)
//        newTitleIconUrl = try values.decodeIfPresent(String.self, forKey: .newTitleIconUrl)
//        sortId = try values.decodeIfPresent(String.self, forKey: .sortId)
//        titleIconUrl = try values.decodeIfPresent(String.self, forKey: .titleIconUrl)
//    }
    
    
}

class CodableComic : Codable {
    
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
    
    
//    enum CodingKeys: String, CodingKey {
//        case authorName = "author_name"
//        case comicId = "comicId"
//        case cornerInfo = "cornerInfo"
//        case cover = "cover"
//        case descriptionField = "description"
//        case isVip = "is_vip"
//        case name = "name"
//        case shortDescription = "short_description"
//        case subTitle = "subTitle"
//        case tags = "tags"
//    }
//    required init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        authorName = try values.decodeIfPresent(String.self, forKey: .authorName)
//        comicId = try values.decodeIfPresent(Int.self, forKey: .comicId)
//        cornerInfo = try values.decodeIfPresent(String.self, forKey: .cornerInfo)
//        cover = try values.decodeIfPresent(String.self, forKey: .cover)
//        descriptionField = try values.decodeIfPresent(String.self, forKey: .descriptionField)
//        isVip = try values.decodeIfPresent(Int.self, forKey: .isVip)
//        name = try values.decodeIfPresent(String.self, forKey: .name)
//        shortDescription = try values.decodeIfPresent(String.self, forKey: .shortDescription)
//        subTitle = try values.decodeIfPresent(String.self, forKey: .subTitle)
//        tags = try values.decodeIfPresent([String].self, forKey: .tags)
//    }
    
    
}
