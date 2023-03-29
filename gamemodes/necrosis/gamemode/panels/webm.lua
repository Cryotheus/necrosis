--https://raw.githubusercontent.com/Cryotheus/necrosis/master/_internet/test.webm
--locals
local PANEL = {}
local video_html = [[
<body style="margin: 0;">
	<video autoplay disableremoteplayback disablepictureinpicture loop muted height=100% width=100%>
		<source src="VIDEO" type="video/webm">
	</video>
	<script defer>
let loaded = false
let video = document.querySelector("video")

video.oncanplaythrough = (event) => {
	if (loaded) return
	loaded = true
	video.removeAttribute("muted")
}
	</script>
</body>]]

--panel functions
function PANEL:Init()
	local html = vgui.Create("HTML", self)
	self.HTMLPanel = html

	html:Dock(FILL)
end

function PANEL:SetURL(url) self.HTMLPanel:SetHTML(string.gsub(video_html, "VIDEO", url)) end

--post
derma.DefineControl("NecrosisWEBM", "WEBM video player.", PANEL, "Panel")