<!doctype html>
<html>
	<head>
		<shiro:hasRole name="Administrator">
			<meta name="layout" content="main">
		</shiro:hasRole>
		<shiro:hasRole name="SchoolAdmin">
			<meta name="layout" content="schoolAdmin">
		</shiro:hasRole>
		<title><g:message code="sociometricTestResults.directedGraph.header" default="Sociogram" /></title>
	
		<link rel="stylesheet" href="${resource(dir: 'd3/css', file: 'd3.css')}"> 
	
		<script src="${resource(dir: 'd3', file: 'd3.v3.js')}"></script>
		<script src="${resource(dir: 'd3', file: 'bullet.js')}"></script>
		<script src="${resource(dir: 'd3', file: 'radar-chart.js')}"></script>

		<style type="text/css">
		
		path.link {
		  fill: none;
		  stroke: #666;
		  //stroke: black;
		  stroke-width: 1.5px;
		}
		
		path.link.mute {
			stroke-width: 0.5px;
			stroke: #000;
			stroke-dasharray: 0,5 1;
		}
		
		path.link.selected {
			stroke-width: 3px;
			stroke: #005580;
		}		

		path.link.outcoming {
			stroke-width: 3px;
			stroke: green;
		}
		
		marker#licensing {
		  fill: green;
		}
		
		path.link.licensing {
		  stroke: green;
		}
		
		path.link.resolved {
		  stroke-dasharray: 0,2 1;
		}
		
		circle {
		  fill: #666;
		  stroke: black;
		  //stroke-width: 5px;
		}
		
		text {
		  font: 10px sans-serif;
		  pointer-events: none;
		}
		
		text.shadow {
		  stroke: #fff;
		  stroke-width: 3px;
		  stroke-opacity: .8;
		}
		
		#tooltip {
			position:absolute;
			width: 300px;
			height: auto;
			padding: 10px;
			background-color: white;
			-webkit-border-radius: 10px;
			-moz-border-radius: 10px;
			border-radius: 10px;
			-webkit-box-shadow: 4px 4px 10px rgba(0, 0, 0, 0.4);
			-moz-box-shadow: 4px 4px 10px rgba(0, 0, 0, 0.4);
			box-shadow: 4px 4px 10px rgba(0, 0, 0, 0.4);
			//pointer-events: none;
		}
		
		#tooltip.hidden {
			display: none;
		}
		
		#tooltip p {
			margin: 0;
			font-family: sans-serif;
			font-size: 14px;
			line-height: 20px;
			text-align: center;
		}
		
			.bullet { font: 12px sans-serif; }
			.bullet .marker { stroke: #000; stroke-width: 2px; }
			.bullet .tick line { stroke: #666; stroke-width: .5px; }
			.bullet .range.s0 { fill: #eee; }
			.bullet .range.s1 { fill: #ddd; }
			.bullet .range.s2 { fill: #ccc; }
			.bullet .range.s3 { fill: #bbb; }
			.bullet .range.s4 { fill: #aaa; }
			.bullet .measure.s0 { fill: lightsteelblue; }
			.bullet .measure.s1 { fill: steelblue; }
			//.bullet .measure.s1 { fill: steelblue; }
			.bullet .title { font-size: 14px; font-weight: bold; }
			.bullet .subtitle { fill: #666; }	
		
		</style>

	</head>
	
	<body>
	
		<ul class="breadcrumb">
			<shiro:hasRole name="Administrator">
				<li><a href="${createLink(uri: "/socialGroup/schoolList?city=${socialGroup?.parent?.geo.id}&country=${socialGroup?.parent?.geo?.parent.id}")}"><g:message code="socialGroup.school.list.header" default="Schools" /></a> <span class="divider">/</span></li>
				<li><a href="${createLink(uri: "/socialGroup/groupList?school=${socialGroup?.parent.id}&stage=${socialGroup?.stage.id}&period=${socialGroup?.period.id}&city=${socialGroup?.parent?.geo.id}&country=${socialGroup?.parent?.geo?.parent.id}")}"><g:message code="socialGroup.group.list.header" default="Groups" /></a> <span class="divider">/</span></li>
			</shiro:hasRole>
			<shiro:hasRole name="SchoolAdmin">
				<li><a href="${createLink(uri: "/schoolAdmin/groupList?school=${socialGroup?.parent.id}&stage=${socialGroup?.stage.id}&period=${socialGroup?.period.id}&city=${socialGroup?.parent?.geo.id}&country=${socialGroup?.parent?.geo?.parent.id}")}"><g:message code="socialGroup.group.list.header" default="Groups" /></a> <span class="divider">/</span></li>
			</shiro:hasRole>
			<li class="active"><g:message code="sociometricTestResults.directedGraph.header" default="Sociogram"/></li>
		</ul>
		
		<!-- Page Header -->
		<div>
			<h1>
				<i class="icon-retweet"></i> <g:message code="sociometricTestResults.directedGraph.header" default="Sociogram"/> <small><strong>${socialGroup?.parent.name} (${socialGroup?.stage.name}, ${socialGroup?.period.name} ${socialGroup.name})</strong></small>
			</h1>
		</div> <!-- page-header -->
		
		<g:hiddenField id= "socialGroup" name="socialGroup" value="${socialGroup.id}" />
		<g:hiddenField id= "restURI" name="restURI" value="${restURI}" />
		<g:hiddenField id= "photoURL" name="photoURL" value="${photoURL}" />
		
		<div>
		
			<ul class="nav nav-tabs">
				<g:each var="test" in="${sociometricTests}">
				<g:each var="sociometricCriteria" in="${test.sociometricCriteria}">
				<li <g:if test="${test == sociometricTest}"> class="active" </g:if>>
					<a href="${createLink(uri: "/sociometricTestResults/directedGraph/${test.id}")}"><g:message code="${sociometricCriteria.code}" default="${sociometricCriteria.name}" /></a>
				</li>							
				</g:each>
				</g:each>
			</ul>

			<g:set var="i" value="${0}" />
			<div class="controlsXXX">
				<fieldset id="type">

					<g:each var="sociometricCriteria" in="${sociometricTest.sociometricCriteria}">
					<!-- <p><g:message code="${sociometricCriteria.code}" default="${sociometricCriteria.name}" /></p> -->
					<g:each var="sociometricCriteriaResponse" in="${sociometricCriteria.sociometricCriteriaResponses}">

						
						<label class="radio">
							<input type="radio" name="type" id="type_${i}" value="${sociometricCriteriaResponse.question}">
							<g:message code="${sociometricCriteriaResponse.question}" default="${sociometricCriteriaResponse.question}" />
						</label>
						
						<g:set var="i" value="${i + 1}" />
					</g:each>
					</g:each>

				</fieldset>
			</div>
			<div>
				<label class="checkbox">
					<input id= "showNodeNames" type="checkbox"> <g:message code="sociogram.showNodeNames" default="Show Node Names" />
				</label>				
			</div>
			
			<div id="tooltip" class="hidden">
				<div>
					<p><strong><span id="groupmember_name">**</span></strong></p>
					<img id="groupmember_photo" class="image-photo" style="display: block; margin-left: auto; margin-right: auto";/>
				</div>
				<br>

			    <div class="btn-group">
				    <a class="btn dropdown-toggle btn-info" data-toggle="dropdown" href="#">
					    Resultados
					    <span class="caret"></span>
				    </a>
				    <ul class="dropdown-menu">
						<li id="navBullying"><a id="bullying-chart">Bullying</a></li>
						<li id="navBullymetric"><a id="bullymetric-chart">Bullymetrica</a></li>
						<li id="navCompetency"><a id="competency-chart">Competencias</a></li>
						<li id="navCuentaConmigo"><a id="cuentaconmigo-chart">Cuenta Conmigo</a></li>
				    </ul>
			    </div>
			    <br>
				
				<div id="bulletchart">
					<h5>Bullying</h5>
				</div>
				<div id="radar-chart" class="hidden">
					<h5>Evaluación por Competencias</h5>
					<table class="table table-condensed table-bordered" >
						<!-- <caption>Evaluación por Competencias</caption> -->
						<thead>
							<tr>
								<th>Factor 1</th>
								<th>Factor 2</th>
								<th>Factor 3</th>
								<th>Factor 4</th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td><span id="f1">*</span></td>
								<td><span id="f2">*</span></td>
								<td><span id="f3">*</span></td>
								<td><span id="f4">*</span></td>
							</tr>
						</tbody>
					</table>				
				</div>
				<div id="bullymetric" class="hidden">
					<h5>Bullymetrica</h5>
					<table class="table table-condensed table-bordered" >
						<!-- <caption>Bullymetrica</caption> -->
						<thead>
							<tr>
								<th>NEAP</th>
								<th>IGAP</th>
								<th>IMAP</th>
							</tr>
						</thead>
						<tbody>
							<tr>
								<td><span id="neap">*</span></td>
								<td><span id="igap">*</span></td>
								<td><span id="imap">*</span></td>
							</tr>
						</tbody>
					</table>
				</div>
				<div id="cuentaconmigo" class="hidden">
					<h5>Cuenta Conmigo</h5>
					<g:hiddenField id= "sumCongruencia" name="sumCongruencia" value="0" />
					<g:hiddenField id= "sumEmpatia" name="sumEmpatia" value="0" />
					<g:hiddenField id= "sumAPI" name="sumAPI" value="0" />
					<g:hiddenField id= "descriptionCongruencia" name="descriptionCongruencia" value="" />
					<g:hiddenField id= "descriptionEmpatia" name="descriptionEmpatia" value="" />
					<g:hiddenField id= "descriptionAPI" name="descriptionAPI" value="" />
				</div>
			</div>		
			
			<div style="width: 100%">
				<div id="loading" style="float: right; width: 80%;"></div>
				<div id="graph" style="float: right; width: 80%;"></div>
			</div>
			
			<script src="${resource(dir: 'd3/js', file: 'd3-directedGraph.js')}"></script>
			<script src="${resource(dir: 'js', file: 'jquery.json-2.4.min.js')}"></script>
			

		</div>		
	
	</body>
</html>