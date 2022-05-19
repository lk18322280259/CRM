<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
  String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getContextPath()+"/";
//	以上等同于"http://127.0.0.1:8080/crm/"
%>
<html>
<head>
  <base href="<%=basePath%>">
  <meta charset="UTF-8">

  <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
  <link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

  <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
  <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
  <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
  <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

  <link rel="stylesheet" type="text/css" href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css">
  <script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
  <script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>
  <script>
    $(function() {

      $("#demo_pag1").bs_pagination({
        currentPage:1,
        rowsPerPage:10,
        totalRows:1000,
        totalPages:100,

        visiblePageLinks:5,//最多可以显示的卡片数

        showGoToPage: true,
        showRowsPerPage: true,
        showRowsInfo: true,

        //改变页号时触发
        onChangePage:function (event,pageObj){
          //js代码
          alert("aaa");
          alert(pageObj.currentPage);
          alert(pageObj.rowsPerPage);
        }
      });
    });
  </script>
</head>
  <body>
    <div id="demo_pag1"></div>
  </body>
</html>
