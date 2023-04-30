<svg id="back">
	<defs>
		<pattern id="stripes" patternUnits="userSpaceOnUse" width="20" height="20">
			<path d="M-1,1 l2,-2 M0,20 l20,-20 M19,21 l2,-2" stroke="#000" stroke-width="1" />
			<circle cx="5" cy="5" r="12" stroke="black" stroke-width="1" fill="green" />
		</pattern>
	</defs>
	<rect width="100%" height="100%" fill="url(#stripes)" />
</svg>

<slot />

<style>
	#back {
		background-color: purple;
		top: 0px;
		left: 0px;
		width: 100%;
		height: 100%;
		z-index: -1;
		position: absolute;
	}
</style>
