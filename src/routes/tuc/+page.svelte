<script lang="ts">
	let showWardrobe = false;
	let hideAll= false
</script>

<svg id="back">
	<defs>
		<pattern id="stripes" patternUnits="userSpaceOnUse" width="20" height="20">
			<path d="M-1,1 l2,-2 M0,20 l20,-20 M19,21 l2,-2" stroke="#000" stroke-width="1" />
			<circle cx="5" cy="5" r="10" stroke="black" stroke-width="1" fill="green" />
		</pattern>
	</defs>
	<rect width="100%" height="100%" fill="url(#stripes)" />
</svg>

{#if hideAll=== false}
<div>
	<svg>
		<rect
			x="50"
			y="56"
			width="300"
			height="100"
			style="fill:rgb(0,0,255);stroke-width:3;stroke:rgb(0,0,0)"
		/>
	</svg>
	<button class="big-button" on:click={() => (hideAll = true)}>play now &#x25B6;</button>
	<button class="big-button" on:click={() => (showWardrobe = true)}>wardrobe!</button>
</div>
{:else}
<button on:click={() => hideAll = false}>back ⇇</button>
{/if}
{#if showWardrobe}
	<div id="wardrobe">
		<div class="container">
			<div>select your skin</div>
			<button class="close" on:click={() => (showWardrobe = false)}>x</button>
		</div>
	</div>
{/if}

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

	.big-button {
		height: 129px;
		width: 200px;
		font-size: 39px;
		font-weight: 900;
		color: blanchedalmond;
		background-color: #8516ec;
	}

	#wardrobe {
		position: absolute;
		top: 50%;
		left: 50%;
		transform: translate(-50%, -50%);
		width: 97%;
		height: 299px;
		background-color: blue;
		color: white;
		padding: 20px;
		z-index: 3;
	}

	.container {
		display: flex;
	}
	.close {
		margin-left: auto;
	}
</style>
