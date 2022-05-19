<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
	String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+request.getContextPath()+"/";
//	以上等同于"http://127.0.0.1:8080/crm/"
%>
<html>
<head>
	<!-- 下面路径都从base开头找 -->
	<base href="<%=basePath%>">
<meta charset="UTF-8">
<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript">
	$(function (){
		//给整个浏览器加上键盘按下事件（回车登录）
		$(window).keydown(function (e){
			//如果按下回车键，提交请求
			if(e.keyCode===13){
				$("#loginBtn").click();
			}
		});
		//给"登录"按钮添加功能
		$("#loginBtn").click(function (){
			//收集参数
			var loginAct = $.trim($("#loginAct").val());
			var loginPwd = $.trim($("#loginPwd").val());
			var idRemPwd = $("#isRemPwd").prop("checked");

			//发送请求
			$.ajax({
				url:'settings/qx/user/login.do',
				data:{
					loginAct:loginAct,
					loginPwd:loginPwd,
					idRemPwd:idRemPwd
				},
				type:'post',
				dataType:'json',
				success:function (data) {
					if(data.code=="1"){
						//跳转到业务主界面
						$("#msg").text("验证成功！");
						window.location.href="workbench/index.do";
					}else {
						//提示信息
						$("#msg").html(data.message);
					}
				},
				/**
				 * 当ajax向后台发送请求之前，会自动执行本函数
				 * 该函数的返回值能够决定ajax是否真正向后台发送请求
				 * 如果该函数返回true，则ajax会真正向后台发送请求，否则，如果该函数返回false，则ajax放弃向后台发送请求
				 */
				beforeSend:function () {
					//显示正在验证中。。。
					$("#msg").text("验证中...");
					return true;
				}
			})
		})
	})
</script>
</head>
<body>
	<div style="position: absolute; top: 0px; left: 0px; width: 60%;">
		<img src="image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
	</div>
	<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
		<div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">CRM &nbsp;<span style="font-size: 12px;">&copy;2019&nbsp;动力节点</span></div>
	</div>
	
	<div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
		<div style="position: absolute; top: 0px; right: 60px;">
			<div class="page-header">
				<h1>登录</h1>
			</div>
			<form action="workbench/index.html" class="form-horizontal" role="form">
				<div class="form-group form-group-lg">
					<div style="width: 350px;">
						<input class="form-control" id="loginAct" type="text" value="${cookie.loginAct.value}" placeholder="用户名">
					</div>
					<div style="width: 350px; position: relative;top: 20px;">
						<input class="form-control" id="loginPwd" type="password" value="${cookie.loginPwd.value}" placeholder="密码">
					</div>
					<div class="checkbox"  style="position: relative;top: 30px; left: 10px;">
						<label>
							<c:if test="${not empty cookie.loginAct and not empty cookie.loginPwd}">
								<input type="checkbox" id="isRemPwd" checked>
							</c:if>
							<c:if test="${empty cookie.loginAct or empty cookie.loginPwd}">
								<input type="checkbox" id="isRemPwd">
							</c:if>
							十天内免登录
						</label>
						&nbsp;&nbsp;
						<span id="msg"></span>
					</div>
					<button type="button" id="loginBtn" class="btn btn-primary btn-lg btn-block"  style="width: 350px; position: relative;top: 45px;">登录</button>
				</div>
			</form>
		</div>
	</div>
</body>
</html>