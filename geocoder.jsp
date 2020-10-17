<%@ page language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="j" uri="newland:javajs" %>
<%@ taglib prefix="e" uri="newland:javajsext" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="p" uri="newland:permission" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":"
            + request.getServerPort() + path + "/";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
    <meta charset="utf-8">
    <meta http-equiv="pragma" content="no-cache">
    <meta http-equiv="cache-control" content="no-cache">
    <meta http-equiv="expires" content="0">
    <meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
    <meta http-equiv="description" content="This is my page">
    <%@ include file="/public/public.inc"%>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no, width=device-width">
    <title>地理编码(地址->经纬度)</title>
    <link rel="stylesheet" href="https://a.amap.com/jsapi_demos/static/demo-center/css/demo-center.css"/>
    <script type="text/javascript" src="/javajs/js/javajs-all-notree.js"></script>
	<script type="text/javascript" src="public/jquery-1.8.3.min.js"></script>
	<script type="text/javascript" src="public/public.js"></script>
    <style>
        html,body,#container{
            height:100%;
            width:100%;
        }
        .btn{
            width:10rem;
            margin-left:6.8rem;
        }
    </style>
</head>
<body>
<div id="container"></div>
<div class="input-card" style='width:28rem;'>
    <label style='color:grey'>地理编码，根据地址获取经纬度坐标</label>
    <div class="input-item">
        <div class="input-item-prepend"><span class="input-item-text" >地址</span></div>
        <input id='address'  type="text" value='浙江省宁波市北仑区' >
    </div>
    <div class="input-item">
        <div class="input-item-prepend"><span class="input-item-text">经纬度</span></div>
        <input id='lnglat'   type="text">
    </div>
    <input id="geo" type="button" class="btn" value="确认" onclick="commitPosition()" />
</div>
<script src="https://a.amap.com/jsapi_demos/static/demo-center/js/demoutils.js"></script>
<script type="text/javascript" src="https://webapi.amap.com/maps?v=1.4.15&key=499a5220d96d36c620287abd5aac5697&plugin=AMap.Geocoder"></script>
<script type="text/javascript">
    var url = window.location.href;
    var queryStr = url.substring(url.indexOf('?') + 1);
    var paramObj = Ext.urlDecode(queryStr);

    window.onload=function() {
        let positionAddrName = paramObj.positionAddrName;
        let viewName = paramObj.viewName;
        let longitude = paramObj.longitude; // 经度
        let latitude = paramObj.latitude; // 纬度
        console.log(positionAddrName, viewName, longitude, latitude)
        if (positionAddrName !== undefined) {
            document.getElementById("address").value = positionAddrName;
        }
        if (viewName === 'addLowAddressView') {
            geoCode();
        } else if (viewName === 'editView') {
            document.getElementById("lnglat").value = longitude + ',' + latitude;
            regeoCode();
        }
    };

    var map = new AMap.Map("container", {
        resizeEnable: true
    });

    var geocoder = new AMap.Geocoder({
        //city: "010", //城市设为北京，默认：“全国”
    });

    var marker = new AMap.Marker();

    /**
     * 通过经纬度定位
     */
    function regeoCode() {
        var lnglat  = document.getElementById('lnglat').value.split(',');
        map.add(marker);
        marker.setPosition(lnglat);

        geocoder.getAddress(lnglat, function(status, result) {
            if (status === 'complete'&&result.regeocode) {
                var address = result.regeocode.formattedAddress;
                document.getElementById('address').value = address;
            }else{
                log.error('根据经纬度查询地址失败')
            }
        });
    }

    /**
     * 通过地址定位
     */
    function geoCode() {
        var address  = document.getElementById('address').value;
        geocoder.getLocation(address, function(status, result) {
            if (status === 'complete'&&result.geocodes.length) {
                var lnglat = result.geocodes[0].location
                document.getElementById('lnglat').value = lnglat;
                marker.setPosition(lnglat);
                map.add(marker);
                map.setFitView(marker);
            }else{
                log.error('根据地址查询位置失败');
            }
        });
    }
    // document.getElementById("geo").onclick = geoCode;
    document.getElementById('lnglat').onkeydown = function(e) {
        if (e.keyCode === 13) {
            geoCode();
            return false;
        }
        return true;
    };
    document.getElementById('address').onkeydown = function(e) {
        if (e.keyCode === 13) {
            regeoCode();
            return false;
        }
        return true;
    };
    //为地图注册click事件获取鼠标点击出的经纬度坐标
    map.on('click', function(e) {
        document.getElementById("lnglat").value = e.lnglat.getLng() + ',' + e.lnglat.getLat();
        marker.setPosition(e.lnglat);
    });

    function commitPosition() {
        let lnglat = document.getElementById("lnglat").value.split(",");
        console.log("geocoder.jsp commitPosition == "+lnglat);
        let param = {
            longitude: lnglat[0],
            latitude: lnglat[1]
        }
        parent.sendLnglatInfo(param);
        parent.selectWin.close();
    }
</script>
</body>
</html>