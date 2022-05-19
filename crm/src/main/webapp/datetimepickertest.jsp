<%--
  Created by IntelliJ IDEA.
  User: LuoKai
  Date: 2022/3/7
  Time: 16:54
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getContextPath()+"/";
//	以上等同于"http://127.0.0.1:8080/crm/"
%>
<html>
<head>
  <base href="<%=basePath%>">
  <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
  <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
  <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
  <!--引入开发包-->
  <link rel="stylesheet" href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css">
  <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
  <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
  <script type="text/javascript">
    $(function () {
      //当容器加载完成，对容器加载
      $("#myDate").datetimepicker({
        language:'zh-CN',
        format:'yyyy-mm-dd',
        minView:'month',//可以选择的最小视图，写月表示到日
        initialDate:new Date(),
        autoclose:true,
        todayBtn:true, //是否显示今天按钮
        clearBtn:true //是否显示清空按钮
      });
    })
  </script>
  <title>日历</title>
</head>
<body>
  <input type="text" id="myDate" readonly>
</body>
</html>
