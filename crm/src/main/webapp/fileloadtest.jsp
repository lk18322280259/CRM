<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
  String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
//	以上等同于"http://127.0.0.1:8080/crm/"
%>
<html>
<head>
  <base href="<%=basePath%>">
  <title>演示文件上传</title>
  <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<%--  <script type="text/javascript">--%>
<%--    $(function () {--%>
<%--      //给下载按钮添加事件--%>
<%--      $("#fileUploadBtn").click(function () {--%>
<%--        //发送文件下载请求--%>
<%--        //所有文件下载的请求只能发同步请求--%>
<%--        window.location.href = "workbench/activity/fileUpload.do";--%>
<%--      })--%>
<%--    })--%>
<%--  </script>--%>
</head>
<body>
  <%-- form表单编码格式默认采用urlencode --%>
  <%-- 文件上传编码格式只能用multipart/form-data --%>
  <form action="workbench/activity/fileUpload.do" method="post" enctype="multipart/form-data">
    <input type="file" name="myFile" id="fileUploadBtn"><br>
    <input type="text" name="userName"><br>
    <input type="submit" value="提交">
  </form>
</body>
</html>
