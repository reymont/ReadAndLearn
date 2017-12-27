

C:\workspace\cmi\jtp\dubbox\dubbo-admin\src\main\webapp\WEB-INF\templates\governance\screen\consumers\index.vm


```html
#foreach($consumer in $consumers)
<tr>
	<td><input type="checkbox" name="ids" value="$consumer.id" /></td>
	<td><a href="consumers/$consumer.id">#if($address)$tool.getSimpleName($consumer.service)#else$consumer.address#end</a></td>
    <td>$consumer.application</td>
	<td>
        #if($tool.isInBlackList($consumer))
			<font color="red">$i18n.get("Forbidden")</font>
		#else
			<font color="green">$i18n.get("Allowed")</font>
		#end
    </td>
    <td>
    	#set($mock=$tool.getConsumerMock($consumer))
		#if($mock.equals("force%3Areturn+null"))
			<font color="red">$i18n.get("force.mocked")</font>
		#elseif ($mock.equals("fail%3Areturn+null"))
			<font color="blue">$i18n.get("fail.mocked")</font>
		#else
			<font color="gray">$i18n.get("no.mocked")</font>
		#end
    </td>
    <td>
    	#if($consumer.routes && $consumer.routes.size() > 0)
    		<a href="consumers/$consumer.id/routed">$i18n.get("routed")($consumer.routes.size())</a>
    	#else
    		<font color="gray">$i18n.get("unrouted")</font>
    	#end
    </td>
    <td>
    	#if($consumer.providers && $consumer.providers.size() > 0)
    		<a href="consumers/$consumer.id/notified">$i18n.get("notified")($consumer.providers.size())</a>
    	#else
    		<font color="red">$i18n.get("NoProvider")</font>
    	#end
    </td>
    #if($currentUser.role != "G")
	<td>
		#if($currentUser.hasServicePrivilege($consumer.service))
		<a href="consumers/$consumer.id/edit"><img src="$rootContextPath.getURI("images/ico_edit.png")" width="12" height="12" /><span class="ico_font">$i18n.get("edit")</span></a>
		<span class="ico_line">|</span>
		#if($tool.isInBlackList($consumer))
			<a href="#" onclick="showConfirm('$i18n.get("confirm.allow")', '$consumer.address -&gt; $tool.getSimpleName($consumer.service)', 'consumers/$consumer.id/allow'); return false;"><img src="$rootContextPath.getURI("images/ico_enable.png")" width="12" height="12" /><span class="ico_font">$i18n.get("allow")</span></a>
		#else
			<a href="#" onclick="showConfirm('$i18n.get("confirm.forbid")', '$consumer.address -&gt; $tool.getSimpleName($consumer.service)', 'consumers/$consumer.id/forbid'); return false;"><img src="$rootContextPath.getURI("images/ico_disable.png")" width="12" height="12" /><span class="ico_font">$i18n.get("forbid")</span></a>
		#end
		<span class="ico_line">|</span>
		#if($mock.equals("force%3Areturn+null"))
			<a href="#" onclick="showConfirm('$i18n.get("confirm.cancel.mock")', '$consumer.address -&gt; $tool.getSimpleName($consumer.service)', 'consumers/$consumer.id/recover'); return false;"><img src="$rootContextPath.getURI("images/ico_enable.png")" width="12" height="12" /><span class="ico_font">$i18n.get("cancel.mock")</span></a>
			<span class="ico_line">|</span>
			<a href="#" onclick="showConfirm('$i18n.get("confirm.fail.mock")', '$consumer.address -&gt; $tool.getSimpleName($consumer.service)', 'consumers/$consumer.id/tolerant'); return false;"><img src="$rootContextPath.getURI("images/ico_run.png")" width="12" height="12" /><span class="ico_font">$i18n.get("fail.mock")</span></a>
		#elseif ($mock.equals("fail%3Areturn+null"))
			<a href="#" onclick="showConfirm('$i18n.get("confirm.force.mock")', '$consumer.address -&gt; $tool.getSimpleName($consumer.service)', 'consumers/$consumer.id/shield'); return false;"><img src="$rootContextPath.getURI("images/ico_cancel.png")" width="12" height="12" /><span class="ico_font">$i18n.get("force.mock")</span></a>
			<span class="ico_line">|</span>
			<a href="#" onclick="showConfirm('$i18n.get("confirm.cancel.mock")', '$consumer.address -&gt; $tool.getSimpleName($consumer.service)', 'consumers/$consumer.id/recover'); return false;"><img src="$rootContextPath.getURI("images/ico_enable.png")" width="12" height="12" /><span class="ico_font">$i18n.get("cancel.mock")</span></a>
		#else
			<a href="#" onclick="showConfirm('$i18n.get("confirm.force.mock")', '$consumer.address -&gt; $tool.getSimpleName($consumer.service)', 'consumers/$consumer.id/shield'); return false;"><img src="$rootContextPath.getURI("images/ico_cancel.png")" width="12" height="12" /><span class="ico_font">$i18n.get("force.mock")</span></a>
			<span class="ico_line">|</span>
			<a href="#" onclick="showConfirm('$i18n.get("confirm.fail.mock")', '$consumer.address -&gt; $tool.getSimpleName($consumer.service)', 'consumers/$consumer.id/tolerant'); return false;"><img src="$rootContextPath.getURI("images/ico_run.png")" width="12" height="12" /><span class="ico_font">$i18n.get("fail.mock")</span></a>
		#end
		#end
	</td>
	#end
</tr>
#end
</table>
```