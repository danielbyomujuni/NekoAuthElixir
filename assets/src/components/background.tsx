export default function Background() {
    return (
        <div className={ "fixed w-screen h-screen top-0 left-0 -z-40" }>
            <div className="relative h-full w-full bg-background">
                <div
                    className="absolute left-[-10%] right-0 bottom-[-10%] h-[500px] w-[500px] rounded-full bg-[radial-gradient(circle_farthest-side,rgba(243,139,168,.2),rgba(255,255,255,0))]">
                </div>
                <div
                    className="absolute bottom-0 right-[-10%] top-[-10%] h-[500px] w-[500px] rounded-full bg-[radial-gradient(circle_farthest-side,rgba(243,139,168,.2),rgba(255,255,255,0))]">
                </div>
            </div>
        </div>
    );
}
