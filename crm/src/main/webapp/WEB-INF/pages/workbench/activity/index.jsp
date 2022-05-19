<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/";
//	以上等同于"http://127.0.0.1:8080/crm/"
%>
<html>
<head>
    <base href="<%=basePath%>">
    <meta charset="UTF-8">

    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css"
          rel="stylesheet"/>

    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript"
            src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

    <link rel="stylesheet" type="text/css" href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css">
    <script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
    <script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>

    <script type="text/javascript">

        $(function () {
            //当容器加载完成，对容器加载
            $(".mydate").datetimepicker({
                language: 'zh-CN',
                format: 'yyyy-mm-dd',
                minView: 'month',//可以选择的最小视图，写月表示到日
                initialDate: new Date(),
                autoclose: true,
                todayBtn: true, //是否显示今天按钮
                clearBtn: true //是否显示清空按钮
            });

            //给创建按钮添加单击事件
            $("#createActivityBtn").click(function () {
                //初始化重置表单
                $("#createActivityForm").get(0).reset();
                //弹出创建市场活动的模态窗口
                $("#createActivityModal").modal("show");
            })
            //给保存添加单击事件
            $("#saveCreateActivityBtn").click(function () {
                //收集参数
                var owner = $("#create-marketActivityOwner").val();
                var name = $.trim($("#create-marketActivityName").val());
                var startTime = $("#create-startTime").val();
                var endTime = $("#create-endTime").val();
                var cost = $.trim($("#create-cost").val());
                var describe = $("#create-describe").val();
                //表单验证
                if (owner == "") {
                    alert("所有者不能为空！");
                    return;
                }
                if (name == "") {
                    alert("名称不能为空！");
                    return;
                }
                if (owner == "" && name == "") {
                    alert("所有者和名称不能为空！");
                    return;
                }
                //判断时间不为空前提下判断结束日期大于开始日期
                if (startTime != "" && endTime != "") {
                    //使用字符串比较大小
                    if (startTime > endTime) {
                        alert("结束日期不能比开始日期小");
                        return;
                    }
                }
                //钱只能为非负整数，正则表达式
                var regExp = /^(([1-9]\d*)|0)$/;
                if (!regExp.test(cost)) {
                    alert("成本只能为非负整数");
                    return;
                }
                //发送请求
                $.ajax({
                    url: 'workbench/activity/saveCreateActivity.do',
                    data: {
                        //前面的参数和实体类的属性名保持一致，后面的参数为前端页面收集参数
                        owner: owner,
                        name: name,
                        startDate: startTime,
                        endDate: endTime,
                        cost: cost,
                        description: describe
                    },
                    type: 'post',
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == "1") {
                            //关闭模态窗口
                            $("#createActivityModal").modal("hide");
                            //刷新市场活动，显示第一页数据，保持每页显示条数不变
                            queryActivityByConditionForPage(1, $("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'));
                        } else {
                            //提示信息
                            alert(data.message);
                            //保持模态窗口不关闭
                            $("#createActivityModal").modal("show");
                        }
                    }

                })
            })

            //页面加载完成查询，初始化时查询第一页的10条数据
            queryActivityByConditionForPage(1, 10);

            //给查询按钮绑定事件
            $("#queryActivityBtn").click(function () {
                //查询所有符合条件的第一页以及所有符合条件的总条数
                queryActivityByConditionForPage(1, $("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'));
            })

            //给“全选”按钮添加单击事件
            $("#checkAll").click(function () {
                /*if(this.checked==true){
                    $("#tBody input[type='checkbox]").prop("checked", true);
                }else {
                    $("#tBody input[type='checkbox]").prop("checked", false);
                }*/
                //让子check box和总的check box属性保持一致
                $("#tBody input[type='checkbox']").prop("checked", this.checked);
            })
            /*$("#tBody input[type='checkbox']").click(function () {
                //如果列表中的所有checkbox都选中，则“全选按钮都选中”
                if($("#tBody input[type='checkbox']").size()==$("#tBody input[type='checkbox']:checked").size()){
                    $("#checkAll").prop("checked", true)
                }else {
                    $("#checkAll").prop("checked", false)
                }
            })*/
            $("tBody").on("click", "input[type='checkbox']", function () {
                //如果列表中的所有checkbox都选中，则“全选按钮都选中”
                if ($("#tBody input[type='checkbox']").size() == $("#tBody input[type='checkbox']:checked").size()) {
                    $("#checkAll").prop("checked", true)
                } else {
                    $("#checkAll").prop("checked", false)
                }
            })

            //给删除按钮添加单击事件
            $("#deleteActivity").click(function () {
                //发请求，收集参数
                //获取列表所有被选中的checkBox
                var checkedIds = $("#tBody input[type='checkbox']:checked");
                if (checkedIds.size() == 0) {
                    alert("请选择要删除的市场活动");
                    return;
                }
                if (window.confirm("确定删除吗？")) {
                    var ids = "";
                    $.each(checkedIds, function () {
                        ids += "id=" + this.value + "&";
                    })
                    ids = ids.substr(0, ids.length - 1)
                    //向后台发送请求
                    $.ajax({
                        url: 'workbench/activity/deleteActivityIds.do',
                        data: ids,
                        type: 'post',
                        dataType: 'json',
                        success: function (data) {
                            if (data.code == '1') {
                                //刷新市场活动列表，保持每页显示条数不变
                                queryActivityByConditionForPage(1, $("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'));
                            } else {
                                alert(data.message);
                            }
                        }
                    })
                }
            })

            //给修改按钮添加单击事件
            $("#editActivityBtn").click(function () {
                //收集参数
                //获取列表中被选中的checkbox
                var checkedIds = $("#tBody input[type='checkbox']:checked");
                if (checkedIds.size() == 0) {
                    alert("请选择要删除的市场活动");
                    return;
                }
                if (checkedIds.size() > 1) {
                    alert("每次只能修改一条数据");
                    return;
                }
                var id = checkedIds[0].value;
                //发送请求
                $.ajax({
                    url: 'workbench/activity/queryActivityById.do',
                    data: {
                        id: id
                    },
                    type: 'post',
                    dataType: 'json',
                    success: function (data) {
                        //把市场活动信息显示在模态窗口
                        $("#edit-id").val(data.id);
                        $("#edit-marketActivityOwner").val(data.owner);
                        $("#edit-marketActivityName").val(data.name);
                        $("#edit-startTime").val(data.startDate);
                        $("#edit-endTime").val(data.endDate);
                        $("#edit-cost").val(data.cost);
                        $("#edit-describe").val(data.description);
                        //弹出模态窗口
                        $("#editActivityModal").modal("show");
                    }
                })
            })

            //给更新按钮添加事件
            $("#saveEditActivityBtn").click(function () {
                //收集参数
                var id = $("#edit-id").val();
                var owner = $("#edit-marketActivityOwner").val()
                var name = $.trim($("#edit-marketActivityName").val())
                var startDate = $("#edit-startTime").val()
                var endDate = $("#edit-endTime").val()
                var cost = $.trim($("#edit-cost").val())
                var description = $.trim($("#edit-describe").val())

                //表单验证
                //表单验证
                if (owner == "") {
                    alert("所有者不能为空！");
                    return;
                }
                if (name == "") {
                    alert("名称不能为空！");
                    return;
                }
                if (owner == "" && name == "") {
                    alert("所有者和名称不能为空！");
                    return;
                }
                //判断时间不为空前提下判断结束日期大于开始日期
                if (startDate != "" && endDate != "") {
                    //使用字符串比较大小
                    if (startDate > endDate) {
                        alert("结束日期不能比开始日期小");
                        return;
                    }
                }
                //钱只能为非负整数，正则表达式
                var regExp = /^(([1-9]\d*)|0)$/;
                if (!regExp.test(cost)) {
                    alert("成本只能为非负整数");
                    return;
                }

                $.ajax({
                    url: "workbench/activity/saveEditActivity.do",
                    data: {
                        id: id,
                        owner: owner,
                        name: name,
                        startDate: startDate,
                        endDate: endDate,
                        cost: cost,
                        description: description
                    },
                    type: 'post',
                    dataType: 'json',
                    success: function (data) {
                        if (data.code == "1") {
                            //关闭模态窗口
                            $("#editActivityModal").modal("hide");
                            alert("更新成功");
                            //刷新市场活动，显示第一页数据，保持每页显示条数不变
                            queryActivityByConditionForPage($("#demo_pag1").bs_pagination('getOption', 'currentPage'),
                                $("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'));
                        } else {
                            //提示信息
                            alert(data.message);
                            //保持模态窗口不关闭
                            $("#editActivityModal").modal("show");
                        }
                    }
                })
            })

            //给“批量导出”按钮添加单击事件
            $("#exportActivityAllBtn").click(function () {
                window.location.href = ("workbench/activity/exportAllActivitys.do")
            })

            //给“选择导出”按钮添加单击事件
            $("#exportActivityXzBtn").click(function () {
                //发请求，收集参数
                //获取列表所有被选中的checkBox
                var checkedIds = $("#tBody input[type='checkbox']:checked");
                if (checkedIds.size() == 0) {
                    alert("请选择要导出的市场活动");
                    return;
                }

                var ids = "";
                $.each(checkedIds, function () {
                    ids += "id=" + this.value + "&";
                })
                ids = ids.substr(0, ids.length - 1)
                //向后台发送请求
                url = "workbench/activity/exportActivitysById.do?" + ids
                window.location.href = (url);
            })

            //给”导入“按钮添加单击事件
            $("#importActivityBtn").click(function () {
                //收集参数
                var activityFileName = $("#activityFile").val()//只能获取文件名
                var suffix = activityFileName.substr(activityFileName.lastIndexOf(".") + 1).toLowerCase();
                if(suffix==""){
                    alert("请先选择文件！");
                    return;
                }
                if (suffix != "xls" && suffix != "xlsx") {
                    alert("不支持的文件格式");
                    return;
                }
                //文件保存在表单组件的dom对象($("#activityFile")[0])中,files表示可以同时上传多个文件，获取第一个元素
                var activityFile = $("#activityFile")[0].files[0];
                if (activityFile.size >= 5 * 1024 * 1024) {
                    alert("文件大小不能超过5M");
                    return;
                }
                //ajax上传文件只能用FormData对象，ajax提供的接口，可以模拟键值对向后台提交参数
                //FormData对象不但可以提供文本数据，还可以提交二进制文件
                //发送请求
                var formData = new FormData();
                //key和controller形参相同
                formData.append("multipartFile", activityFile);

                $.ajax({
                    url: 'workbench/activity/importActivity.do',
                    data: formData,
                    processData: false, //设置ajax向后台提交参数之前，是否将参数统一转成字符串，true-转，false-不转，默认是true，文件会发送失败
                    contentType : false, //设置ajax向后台提交参数之前，是否将所有的参数统一按urlencode编码，true-是，false-不是，默认是true
                    type: 'post',
                    dataType: 'json',
                    success:function (data) {
                        if(data.code=="1"){
                            //关闭模态窗口
                            $("#importActivityModal").modal("hide");
                            alert("成功导入"+data.retData+"条记录");
                            //刷新市场活动界面，显示第一个数据
                            queryActivityByConditionForPage(1, $("#demo_pag1").bs_pagination('getOption', 'rowsPerPage'));
                            } else {
                                alert(data.message);
                                //模态窗口不关闭
                                $("#importActivityModal").modal("show");
                            }
                        }
                })
            })

        });

        function queryActivityByConditionForPage(pageNo, pageSize) {
            //当页面加载完，查询所有数据第一页，收集参数
            var name = $("#query-name").val();
            var owner = $("#query-owner").val();
            var startDate = $("#query-startDate").val();
            var endDate = $("#query-endDate").val();
            // var pageNo = 1;
            // var pageSize = 10;

            //发送请求
            $.ajax({
                url: 'workbench/activity/queryActivityByConditionForPage.do',
                data: {
                    name: name,
                    owner: owner,
                    startDate: startDate,
                    endDate: endDate,
                    pageNo: pageNo,
                    pageSize: pageSize,
                },
                type: 'post',
                dataType: 'json',
                success: function (data) {
                    //显示总条数
                    // $("#totalRowsB").text(data.totalRows);
                    //显示市场
                    //遍历activityList，拼接所有行数据
                    var htmlStr = "";
                    $.each(data.activityList, function (index, obj) {

                        //this和obj都表示当前数据
                        htmlStr += "<tr class=\"active\">"
                        htmlStr += "	<td><input type=\"checkbox\" value=\"" + obj.id + "\"/></td>"
                        htmlStr+="<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/activity/detailActivity.do?id="+obj.id+"'\">"+obj.name+"</a></td>";
                        htmlStr += "	<td>" + obj.owner + "</td>"
                        htmlStr += "	<td>" + obj.startDate + "</td>"
                        htmlStr += "	<td>" + obj.endDate + "</td>"
                        htmlStr += "</tr>"
                    });
                    $("#tBody").html(htmlStr);

                    //换页取消全选按钮
                    $("#checkAll").prop("checked", false);

                    //计算总页数
                    var totalPages = 1;
                    if (data.totalRows % pageSize == 0) {
                        totalPages = data.totalRows / pageSize;
                    } else {
                        totalPages = parseInt(data.totalRows / pageSize) + 1;
                    }


                    //调用分页工具函数
                    //分页插件
                    $("#demo_pag1").bs_pagination({
                        currentPage: pageNo,
                        rowsPerPage: pageSize,
                        totalRows: data.totalRows,
                        totalPages: totalPages,

                        visiblePageLinks: 5,//最多可以显示的卡片数

                        showGoToPage: true,
                        showRowsPerPage: true,
                        showRowsInfo: true,

                        //改变页号时触发
                        onChangePage: function (event, pageObj) {
                            //js代码
                            // alert("aaa");
                            // alert(pageObj.currentPage);
                            // alert(pageObj.rowsPerPage);
                            queryActivityByConditionForPage(pageObj.currentPage, pageObj.rowsPerPage);
                        }
                    });
                }
            })
        }
    </script>
</head>
<body>

<!-- 创建市场活动的模态窗口 -->
<div class="modal fade" id="createActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
            </div>
            <div class="modal-body">

                <form id="createActivityForm" class="form-horizontal" role="form">

                    <div class="form-group">
                        <label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="create-marketActivityOwner">
                                <c:forEach items="${userList}" var="u">
                                    <option value="${u.id}">${u.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-marketActivityName">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control mydate" id="create-startTime" readonly>
                        </div>
                        <label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control mydate" id="create-endTime" readonly>
                        </div>
                    </div>
                    <div class="form-group">

                        <label for="create-cost" class="col-sm-2 control-label">成本</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="create-cost">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="create-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="create-describe"></textarea>
                        </div>
                    </div>

                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="saveCreateActivityBtn">保存</button>
            </div>
        </div>
    </div>
</div>

<!-- 修改市场活动的模态窗口 -->
<div class="modal fade" id="editActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
            </div>
            <div class="modal-body">

                <form class="form-horizontal" role="form">
                    <input type="hidden" id="edit-id"/>
                    <div class="form-group">
                        <label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-marketActivityOwner">
                                <c:forEach items="${userList}" var="u">
                                    <option value="${u.id}">${u.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-marketActivityName" value="发传单">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control mydate" id="edit-startTime" value="2020-10-10"
                                   readonly>
                        </div>
                        <label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control mydate" id="edit-endTime" value="2020-10-20"
                                   readonly>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-cost" class="col-sm-2 control-label">成本</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-cost" value="5,000">
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                        <div class="col-sm-10" style="width: 81%;">
                            <textarea class="form-control" rows="3" id="edit-describe">市场活动Marketing，是指品牌主办或参与的展览会议与公关市场活动，包括自行主办的各类研讨会、客户交流会、演示会、新产品发布会、体验会、答谢会、年会和出席参加并布展或演讲的展览会、研讨会、行业交流会、颁奖典礼等</textarea>
                        </div>
                    </div>

                </form>

            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button type="button" class="btn btn-primary" id="saveEditActivityBtn">更新</button>
            </div>
        </div>
    </div>
</div>

<!-- 导入市场活动的模态窗口 -->
<div class="modal fade" id="importActivityModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">导入市场活动</h4>
            </div>
            <div class="modal-body" style="height: 350px;">
                <div style="position: relative;top: 20px; left: 50px;">
                    请选择要上传的文件：<small style="color: gray;">[仅支持.xls/.xlsx]</small>
                </div>
                <div style="position: relative;top: 40px; left: 50px;">
                    <input type="file" id="activityFile">
                </div>
                <div style="position: relative; width: 400px; height: 320px; left: 45% ; top: -40px;">
                    <h3>重要提示</h3>
                    <ul>
                        <li>操作仅针对Excel，仅支持后缀名为xls/xlsx的文件。</li>
                        <li>给定文件的第一行将视为字段名。</li>
                        <li>请确认您的文件大小不超过5MB。</li>
                        <li>日期值以文本形式保存，必须符合yyyy-MM-dd格式。</li>
                        <li>日期时间以文本形式保存，必须符合yyyy-MM-dd HH:mm:ss的格式。</li>
                        <li>默认情况下，字符编码是UTF-8 (统一码)，请确保您导入的文件使用的是正确的字符编码方式。</li>
                        <li>建议您在导入真实数据之前用测试文件测试文件导入功能。</li>
                    </ul>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                <button id="importActivityBtn" type="button" class="btn btn-primary">导入</button>
            </div>
        </div>
    </div>
</div>


<div>
    <div style="position: relative; left: 10px; top: -10px;">
        <div class="page-header">
            <h3>市场活动列表</h3>
        </div>
    </div>
</div>
<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
    <div style="width: 100%; position: absolute;top: 5px; left: 10px;">

        <div class="btn-toolbar" role="toolbar" style="height: 80px;">
            <form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">名称</div>
                        <input class="form-control" type="text" id="query-name">
                    </div>
                </div>

                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">所有者</div>
                        <input class="form-control" type="text" id="query-owner">
                    </div>
                </div>


                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">开始日期</div>
                        <input class="form-control  mydate" type="text" id="query-startDate"/>
                    </div>
                </div>
                <div class="form-group">
                    <div class="input-group">
                        <div class="input-group-addon">结束日期</div>
                        <input class="form-control  mydate" type="text" id="query-endDate">
                    </div>
                </div>

                <button type="button" class="btn btn-default" id="queryActivityBtn">查询</button>

            </form>
        </div>
        <div class="btn-toolbar" role="toolbar"
             style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-primary" id="createActivityBtn"><span
                        class="glyphicon glyphicon-plus"></span> 创建
                </button>
                <button type="button" class="btn btn-default" id="editActivityBtn"><span
                        class="glyphicon glyphicon-pencil"></span> 修改
                </button>
                <button type="button" class="btn btn-danger" id="deleteActivity"><span
                        class="glyphicon glyphicon-minus"></span> 删除
                </button>
            </div>
            <div class="btn-group" style="position: relative; top: 18%;">
                <button type="button" class="btn btn-default" data-toggle="modal" data-target="#importActivityModal">
                    <span class="glyphicon glyphicon-import"></span> 上传列表数据（导入）
                </button>
                <button id="exportActivityAllBtn" type="button" class="btn btn-default"><span
                        class="glyphicon glyphicon-export"></span> 下载列表数据（批量导出）
                </button>
                <button id="exportActivityXzBtn" type="button" class="btn btn-default"><span
                        class="glyphicon glyphicon-export"></span> 下载列表数据（选择导出）
                </button>
            </div>
        </div>
        <div style="position: relative;top: 10px;">
            <table class="table table-hover">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td><input type="checkbox" id="checkAll"/></td>
                    <td>名称</td>
                    <td>所有者</td>
                    <td>开始日期</td>
                    <td>结束日期</td>
                </tr>
                </thead>
                <tbody id="tBody">
                <%--						<tr class="active">--%>
                <%--							<td><input type="checkbox" /></td>--%>
                <%--							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.html';">发传单</a></td>--%>
                <%--                            <td>zhangsan</td>--%>
                <%--							<td>2020-10-10</td>--%>
                <%--							<td>2020-10-20</td>--%>
                <%--						</tr>--%>
                <%--                        <tr class="active">--%>
                <%--                            <td><input type="checkbox" /></td>--%>
                <%--                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.html';">发传单</a></td>--%>
                <%--                            <td>zhangsan</td>--%>
                <%--                            <td>2020-10-10</td>--%>
                <%--                            <td>2020-10-20</td>--%>
                <%--                        </tr>--%>
                </tbody>
            </table>
            <div id="demo_pag1"></div>
        </div>


        <%--			<div style="height: 50px; position: relative;top: 30px;">--%>
        <%--				<div>--%>
        <%--					<button type="button" class="btn btn-default" style="cursor: default;">共<b id="totalRowsB">50</b>条记录</button>--%>
        <%--				</div>--%>
        <%--				<div class="btn-group" style="position: relative;top: -34px; left: 110px;">--%>
        <%--					<button type="button" class="btn btn-default" style="cursor: default;">显示</button>--%>
        <%--					<div class="btn-group">--%>
        <%--						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">--%>
        <%--							10--%>
        <%--							<span class="caret"></span>--%>
        <%--						</button>--%>
        <%--						<ul class="dropdown-menu" role="menu">--%>
        <%--							<li><a href="#">20</a></li>--%>
        <%--							<li><a href="#">30</a></li>--%>
        <%--						</ul>--%>
        <%--					</div>--%>
        <%--					<button type="button" class="btn btn-default" style="cursor: default;">条/页</button>--%>
        <%--				</div>--%>
        <%--				<div style="position: relative;top: -88px; left: 285px;">--%>
        <%--					<nav>--%>
        <%--						<ul class="pagination">--%>
        <%--							<li class="disabled"><a href="#">首页</a></li>--%>
        <%--							<li class="disabled"><a href="#">上一页</a></li>--%>
        <%--							<li class="active"><a href="#">1</a></li>--%>
        <%--							<li><a href="#">2</a></li>--%>
        <%--							<li><a href="#">3</a></li>--%>
        <%--							<li><a href="#">4</a></li>--%>
        <%--							<li><a href="#">5</a></li>--%>
        <%--							<li><a href="#">下一页</a></li>--%>
        <%--							<li class="disabled"><a href="#">末页</a></li>--%>
        <%--						</ul>--%>
        <%--					</nav>--%>
        <%--				</div>--%>
        <%--			</div>--%>

    </div>

</div>
</body>
</html>