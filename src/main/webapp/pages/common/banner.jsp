<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%@ taglib prefix="ajax" uri="/tags/ajaxtags" %>


<%@ page import="org.openelisglobal.common.action.IActionConstants,
				 org.openelisglobal.common.util.ConfigurationProperties,
				 org.openelisglobal.common.util.ConfigurationProperties.Property,
				 org.openelisglobal.internationalization.MessageUtil,
				 org.openelisglobal.common.util.Versioning,
                 org.openelisglobal.login.valueholder.UserSessionData,
				 org.openelisglobal.common.services.NotificationService, 
				 org.openelisglobal.menu.util.MenuUtil,
				 org.openelisglobal.common.form.BaseForm,
				 org.owasp.encoder.Encode"%>

<%
	boolean languageSwitch = "true".equals(ConfigurationProperties.getInstance().getPropertyValue(Property.languageSwitch));
%>

<c:set var="formName" value="${form.formName}"/>


<script>
function /*void*/ setLanguage( language ){
	//this weirdness is because we want the language to which we are changing, not the one we are in
	if( language.includes('en') ){
	    update = confirm("Changing the language will affect all logged in users ");
	} else if( language.includes('fr') ){
		update = confirm( "Modification de la langue affectera tous les utilisateurs enregistrés");
	}
	if( update ){
		var url = new URL(window.location.href);
		url.searchParams.set('lang', language);
		window.location.href = url.toString();
	}
}


//Note this is hardcoded for haiti clinical.  Message resources would be a good way to get both language and context
function displayHelp(){

    var url = 'documentation/' + '<%= MessageUtil.getContextualMessage("documentation") %>';

	var	newwindow=window.open( url,'name','height=1000,width=850, menuBar=yes');

	if (window.focus) {newwindow.focus()}
}

function getCsrfToken() {
	if (typeof customGetCsrfToken === "function") {
		return customGetCsrfToken();
	} else {
		return document.getElementById("logout-form").elements["_csrf"].value;
	}
}

</script>

<%-- New additions below by mark47 --%>
<link rel="stylesheet" type="text/css" href="css/menu.css?" />

<%-- Begin new menu --%>

<script type="text/javascript" src="scripts/menu/hoverIntent.js?"></script>
<script type="text/javascript" src="scripts/menu/superfish.js?"></script>
<script type="text/javascript" src="scripts/menu/supersubs.js?"></script>
<script type="text/javascript" src="scripts/menu/supposition.js?"></script>
<script type="text/javascript" src="scripts/moment.min.js"></script>
<script type="text/javascript">
	
	// initialize superfish menu plugin. supposition added to allow sub-menus on left when window size is too small.
	jQuery(function(){
		jQuery('ul.nav-menu').supersubs({
			minWidth: 9,
			maxWidth: 100,
			extraWidth: 1
		}).superfish({
			delay: 400,
			speed: 0
		}).supposition();
	});
</script>

<div id="header">
  	<div id="oe-logo" onclick="navigateToHomePage();">
  		<img id="oe-logo-img" src="images/openelis_logo.png" title="OpenELIS" alt="OpenELIS" width="auto" height="71"/>
  	</div>
	<div style="margin-left: 94px">
 		<div style="display: block">
			<%
				UserSessionData usd = null;
				NotificationService ns = new NotificationService(); 
				if (request.getSession().getAttribute(IActionConstants.USER_SESSION_DATA) != null) {
					usd = (UserSessionData) request.getSession().getAttribute(IActionConstants.USER_SESSION_DATA);
					String saveDate = ns.getLoginFromCombinedId(usd.getLoginName()).toString();

			%>

			<script type="text/javascript">
				function showExpiaryNotificationMessage() {
					var now = moment().format('DD-MMMM-YYYY, h:mm:ssA');
				    var date_string = '<%=Encode.forJavaScript(saveDate)%>';
                    var expiration = moment(date_string).format("YYYY-MM-DD");
                    var current_date = moment().format("YYYY-MM-DD");
                    var hours = moment(expiration).diff(current_date, 'hours');
                       alert(now + ' Your password will expire on '  +  date_string  + 'You have ' + hours + ' hours left .Please set new password '); 
		 		}
			</script>
			<spring:url value="/Logout" var="loginurl"/>
			<form id="logout-form" method="post" action="${loginurl}">
			<div id="user-info"><div><%=usd.getElisUserName()%> - 
			<input type="submit" value="<spring:message code="homePage.menu.logOut.toolTip"/>" class="btn-link"/>
			<input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}"/> 			
			</div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</div><img id="oe-bell-img" src="images/bell-notification-icon-svg.png" onclick="showExpiaryNotificationMessage()" alt="" width="auto" height="30"/>	
			</form>
			<%
		        }
	        %>
  	  		<div id="oe-title" onclick="navigateToHomePage();"><c:out value="${oeTitle}" /></div>
  		</div>  
  		<div id="oe-version" style="display: block">
    		<div id="appVersion">
    		<spring:message code="ellis.version" />:&nbsp;
		    <%= ConfigurationProperties.getInstance().getPropertyValue(Property.releaseNumber)%>&nbsp;&nbsp;&nbsp;
		    </div>
    
		    <% if("true".equals(ConfigurationProperties.getInstance().getPropertyValueLowerCase(Property.TrainingInstallation))){ %>
		      <div id="training-alert"><span title="training.note"><spring:message code="training.note"/></span></div>
		    <% } %>
  		</div>
<%	
	if (usd != null) {
%>

<%= MenuUtil.getMenuAsHTML() %>

<%
		}
%>

	</div>
</div> <%-- Closes id=header --%>


<% if( languageSwitch && "loginForm".equals((String) pageContext.getAttribute("formName")) ){ %>
  <div id="language-chooser"><a href="#" onclick="setLanguage('fr_FR')">Français</a>&nbsp;&nbsp;&nbsp;&nbsp;<a href="#" onclick="setLanguage('en_US')">English</a></div>
<% } %>

