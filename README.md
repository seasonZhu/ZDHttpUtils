# ZDHttpUtils
# ZDHttpUtils的使用
ZDHttpUtils是我个人针对的Alamofire和ObjectMapper封装.
其中我也使用了SwiftJSON,主要是为了在控制台上打印漂亮的JSON
里面自带了一个拦截器InterceptHandle主要是针对数据进行处理和界面的loading的简单展示,这其中我使用了Toast,其实Toast功能并不是特别强大,我正在考虑使用自己写的SwiftHud进行替换.

好了,说了这么多,我就想说说我这个ZDHttpUtils的用法.
##输入请求的接口,请求参数,以及遵守Mappable协议的模型,那么你就可以拿到数据了


```
let callbackHandler = CallbackHandler<ResponseArray<Item>>()
            				.onSuccess { (model, models, data, jsonString, httpResponse) in
                				guard let unwrapedModel = model else { return }
                				print(unwrapedModel)
            				}.onFailure { (data, error, _) in
                				print(String(describing: data), String(describing: error))
            				}.onMessage { (message) in
                				print(message)
        				}
        
HttpUtils.request(method: .post, url: "http://sun.topray-media.cn/tz_inf/api/topics", parameters: nil, interceptHandle: InterceptHandle(), callbackHandler: callbackHandler)
```

这个上面我特别说明一下ResponseArray<Item>这个类型,你可以不理解这个是什么.你理解它是遵守Mappable协议的一个class或者struct即可.
之后的事就是严格按照规则写ObjectMapper的映射关系就可以了.

当然,以上是一个最简单的用法,你完全可以通过业务进行更细化的网络请求,我提供一个一般的写法和一个比较类似于Moya的写法,至于怎么选择,各位自己用就行.

##以下封装的业务层:
遵守HttpUrlProtocol协议,将baseUrl和每个详细的api进行拆分.
遵守HttpRequestProtocol协议,将业务的每个请求进行拆分,然后进行请求.BaseDao请详细的参看源码.

```
struct CheckoutUrl: HttpUrlProtocol {
    static var base: String {
        return "http://sun.topray-media.cn"
    }
    
    static let checkoutApi = "/tz_inf/api/topics"
}

protocol CheckoutRequest: HttpRequestProtocol {
    func getList<T: Mappable>(parameters: Parameters?, interceptHandle: InterceptHandle, callbackHandler: CallbackHandler<T>)
}

class CheckoutDao: BaseDao<CheckoutUrl>, CheckoutRequest {
    func getList<T: Mappable>(parameters: Parameters? = nil, interceptHandle: InterceptHandle, callbackHandler: CallbackHandler<T>) {
        post(api: CheckoutUrl.checkoutApi, interceptHandle: interceptHandle, callbackHandler: callbackHandler)
    }
}

class CheckoutViewModel: BaseViewModel {
    //MARK:- 对象方法使用
    private lazy var dao = CheckoutDao(httpConfig: HttpConfig.Builder().setTimeout(15).isNeedSign(true).constructor)
    
    override var interceptHandle: InterceptHandle {
        return InterceptHandle.Builder().setIsShowToast(false).setIsShowLoading(true).setLoadingText("wait...").constructor
    }
    
    func getList<T: Mappable>(parameters: Parameters? = nil, interceptHandle: InterceptHandle? = nil, callbackHandler: CallbackHandler<T>) {
        dao.getList(parameters: parameters, interceptHandle: interceptHandle ?? self.interceptHandle, callbackHandler: callbackHandler)
    }
}

```


这样就可以进行详细的具体业务请求了.

```
let callbackHandler = CallbackHandler<ResponseArray<Item>>()
            				.onSuccess { (model, models, data, jsonString, httpResponse) in
                				guard let unwrapedModel = model else { return }
                				print(unwrapedModel)
            				}.onFailure { (data, error, _) in
                				print(String(describing: data), String(describing: error))
            				}.onMessage { (message) in
                				print(message)
        				}
        					
CheckoutViewModel().getList(callbackHandler: callbackHandler)
```

##另一种是类似于Moya的风格的业务层封装,当然我可没有Moya那么牛X啦
写一个遵守HttpRequestConvertible协议的枚举类型,然后详细的封装每个Api需要传入的请求方式,编码格式,请求头,和请求Api,那么这些计算属性会根据枚举的switch而后配置化,通过func asURLRequest() throws -> URLRequest的实现,得到一个你需要的urlRequest,然后直接进行请求就可以了

ReflectProtocol是我自己写的一个协议,其目的是将单层的模型转为单层的字典,一般请求的json也是单层吧.

```
/// U17Request
///
/// - home: 表示一个Api
enum U17Request: HttpRequestConvertible {
    
    /// 首页请求
    case home(_ model: ReflectProtocol)
    
    /// RequestConvertible的具体实现
    
    static let baseUrl = "http://app.u17.com"
    
    var method: HTTPMethod {
        switch self {
        case .home:
            return .post
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .home:
            return URLEncoding.default
        }
    }
    
    var header: HTTPHeaders? {
        switch self {
        case .home:
            return ["json": "test"]
        }
    }
    
    var api: String {
        switch self {
        case .home:
            return "/v3/appV3_3/ios/phone/comic/boutiqueListNew"
        }
    }
    
    /// URLRequestConvertible的具体实现
    
    func asURLRequest() throws -> URLRequest {
        let url = try U17Request.baseUrl.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(api))
        urlRequest.httpMethod = method.rawValue
        
        // 增加自定义的请求头
        if let header = self.header {
            for (key, value) in header {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        urlRequest = try encoding.encode(urlRequest, with: parameters)
        
        return urlRequest
    }
    
    ///  这个其实可以集成到协议中 也可以不集成, 这里我没有集成 因为这个值是通过枚举中的model转换而成的
    
    var parameters: Parameters? {
        switch self {
        case .home(let model):
            return model.toDictionary
        }
    }
}

/// 传入的U17Request的模型, 最终会转为字典
struct U17RequestModel: ReflectProtocol {
    var sexType = ""
    var key = ""
    var target = ""
    var version = ""
    var v = ""
    var model = ""
    var device_id = ""
    var time = ""
}

```

然后直接进行请求就可以了

```
let requestModel = U17RequestModel(sexType: "2",
	                                 key: "fabe6953ce6a1b8738bd2cabebf893a472d2b6274ef7ef6f6a5dc7171e5cafb14933ae65c70bceb97e0e9d47af6324d50394ba70c1bb462e0ed18b88b26095a82be87bc9eddf8e548a2a3859274b25bd0ecfce13e81f8317cfafa822d8ee486fe2c43e7acd93e9f19fdae5c628266dc4762060f6026c5ca83e865844fc6beea59822ed4a70f5288c25edb1367700ebf5c78a27f5cce53036f1dac4a776588cd890cd54f9e5a7adcaeec340c7a69cd986:::open",
	                                 target: "U17_3.0",
	                                 version: "3.3.3",
	                                 v: "3320101",
	                                 model: "Simulator",
	                                 device_id: "29B09615-E478-4320-8E6A-55B1DE48CB36",
	                                 time: "\(Int32(Date().timeIntervalSince1970))")
        
typealias ResponseU17 = Response<U17Data>
   
let callbackHandler = CallbackHandler<ResponseU17>()
   
callbackHandler.success = { model, models, data, jsonString, httpResponse in
  guard let unwrapedModel = model else { return }
  print(unwrapedModel)
}
   
callbackHandler.failure = { data, error, _ in
  print(String(describing: data), String(describing: error))
}
   
HttpUtils.request(request: U17Request.home(requestModel), interceptHandle: InterceptHandle(), callbackHandler: callbackHandler)
```

其中请求回调,上传回调,下载回调都支持链式编写,而且请求回调都是通过泛型进行输出的,所以使用起来特别的方便.
还是那句话,丢进去url,请求字段,出入泛型类型,获取数据!

这个框架中的请求的网址都是网上一些文章中的,大家也就适当的使用一下.
这个框架目前还没有cocpods,因为目前测试的面还不够广,觉得写的也不够完善.




